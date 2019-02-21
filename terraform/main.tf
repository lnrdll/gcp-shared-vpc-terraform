provider "google" {
  region = "${var.region}"
}

provider "random" {}

resource "random_id" "host_project_id" {
  byte_length = 4
  prefix      = "${var.project_name}-"
}

resource "random_id" "project_1_id" {
  byte_length = 4
  prefix      = "${var.project_name}-"
}

resource "random_id" "project_2_id" {
  byte_length = 4
  prefix      = "${var.project_name}-"
}

# create a folder to organize the projects
resource "google_folder" "shared_vpc" {
  display_name = "Shared VPC Projects"
  parent       = "organizations/${var.org_id}"
}

# create projects and enable compute service
resource "google_project" "host_project" {
  name                = "Shared Project"
  project_id          = "${random_id.host_project_id.hex}"
  folder_id           = "${google_folder.shared_vpc.name}"
  billing_account     = "${var.billing_id}"
  auto_create_network = false
}

resource "google_project_service" "host_project" {
  project = "${google_project.host_project.project_id}"
  service = "compute.googleapis.com"
}

resource "google_project" "project_1" {
  name            = "Project 1"
  project_id      = "${random_id.project_1_id.hex}"
  folder_id       = "${google_folder.shared_vpc.name}"
  billing_account = "${var.billing_id}"
}

resource "google_project_service" "project_1" {
  project = "${google_project.project_1.project_id}"
  service = "compute.googleapis.com"
}

resource "google_project" "project_2" {
  name            = "Project 2"
  project_id      = "${random_id.project_2_id.hex}"
  folder_id       = "${google_folder.shared_vpc.name}"
  billing_account = "${var.billing_id}"
}

resource "google_project_service" "project_2" {
  project = "${google_project.project_2.project_id}"
  service = "compute.googleapis.com"
}

# enable shared VPC in the host project and attach other projects to it
resource "google_compute_shared_vpc_host_project" "host_project" {
  project    = "${google_project.host_project.project_id}"
  depends_on = ["google_project_service.host_project"]
}

# create shared network
resource "google_compute_network" "shared_network" {
  name                    = "shared-network"
  auto_create_subnetworks = "false"
  project                 = "${google_compute_shared_vpc_host_project.host_project.project}"
  depends_on              = ["google_compute_shared_vpc_host_project.host_project"]
}

resource "google_compute_subnetwork" "shared_network_subnet" {
  name          = "shared-subnet"
  ip_cidr_range = "${var.subnet_cidr}"
  network       = "${google_compute_network.shared_network.self_link}"
  depends_on    = ["google_compute_network.shared_network"]
  region        = "${var.region}"
  project       = "${google_compute_network.shared_network.project}"
}

# enable firewall for ICMP and SSH
resource "google_compute_firewall" "shared_network" {
  name    = "allow-ssh-and-icmp"
  network = "${google_compute_network.shared_network.self_link}"
  project = "${google_compute_network.shared_network.project}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_shared_vpc_service_project" "project_1" {
  host_project    = "${google_project.host_project.project_id}"
  service_project = "${google_project.project_1.project_id}"
  depends_on      = ["google_project_service.host_project", "google_project_service.project_1", "google_compute_subnetwork.shared_network_subnet"]
}

resource "google_compute_shared_vpc_service_project" "project_2" {
  host_project    = "${google_project.host_project.project_id}"
  service_project = "${google_project.project_2.project_id}"
  depends_on      = ["google_project_service.host_project", "google_project_service.project_2", "google_compute_subnetwork.shared_network_subnet"]
}
