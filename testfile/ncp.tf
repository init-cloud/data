#server_image_product_code = "SW.VSVR.OS.LNX64.CNTOS.0703.B050"
#server_product_code = "SVR.VSVR.HICPU.C002.M004.NET.SSD.B050.G002"


resource "ncloud_vpc" "cand1" {
  ipv4_cidr_block = "10.0.0.0/16"
}

resource "ncloud_vpc" "cand2" {
  ipv4_cidr_block = "10.1.0.0/16"
}
resource "ncloud_vpc_peering" "cand1tocand2" {
  name = "cand1tocand2"
  source_vpc_no = ncloud_vpc.cand1.id
  target_vpc_no = ncloud_vpc.cand2.id
}

resource "ncloud_vpc_peering" "cand2tocand1" {
  name = "cand2tocand1"
  source_vpc_no = ncloud_vpc.cand2.id
  target_vpc_no = ncloud_vpc.cand1.id
}


resource "ncloud_subnet" "notlb_cand1" {
  network_acl_no = "${ncloud_vpc.cand1.default_network_acl_no}"
  subnet         = "10.0.1.0/24"
  subnet_type    = "PUBLIC"
  vpc_no         = "${ncloud_vpc.cand1.id}"
  zone           = "KR-2"
}
resource "ncloud_server" "notlb_cand1_cand1" {
  subnet_no = "${ncloud_subnet.notlb_cand1.id}"
  server_image_product_code = "SW.VSVR.OS.LNX64.CNTOS.0703.B050"
  server_product_code = "SVR.VSVR.HICPU.C002.M004.NET.SSD.B050.G002"
  is_encrypted_base_block_storage_volume = true
}


resource "ncloud_subnet" "notlb_cand2" {
  network_acl_no = "${ncloud_vpc.cand1.default_network_acl_no}"
  subnet         = "10.0.2.0/24"
  subnet_type    = "PUBLIC"
  vpc_no         = "${ncloud_vpc.cand1.id}"
  zone           = "KR-2"
}
resource "ncloud_server" "notlb_cand1_cand2" {
  subnet_no = "${ncloud_subnet.notlb_cand2.id}"
  server_image_product_code = "SW.VSVR.OS.LNX64.CNTOS.0703.B050"
  server_product_code = "SVR.VSVR.HICPU.C002.M004.NET.SSD.B050.G002"
}


resource "ncloud_subnet" "lb1_cand2" {
  network_acl_no = "${ncloud_vpc.cand2.default_network_acl_no}"
  subnet         = "10.1.2.0/24"
  subnet_type    = "PUBLIC"
  vpc_no         = "${ncloud_vpc.cand2.id}"
  zone           = "KR-2"
  usage_type     = "GEN"
}
resource "ncloud_server" "lb1_cand1" {
  subnet_no = "${ncloud_subnet.lb1_cand2.id}"
  server_image_product_code = "SW.VSVR.OS.LNX64.CNTOS.0703.B050"
  server_product_code = "SVR.VSVR.HICPU.C002.M004.NET.SSD.B050.G002"
  is_encrypted_base_block_storage_volume = true
}
resource "ncloud_server" "lb1_cand2" {
  subnet_no = "${ncloud_subnet.lb1_cand2.id}"
  server_image_product_code = "SW.VSVR.OS.LNX64.CNTOS.0703.B050"
  server_product_code = "SVR.VSVR.HICPU.C002.M004.NET.SSD.B050.G002"
}
resource "ncloud_server" "lb1_cand3" {
  subnet_no = "${ncloud_subnet.lb1_cand2.id}"
  server_image_product_code = "SW.VSVR.OS.LNX64.CNTOS.0703.B050"
  server_product_code = "SVR.VSVR.HICPU.C002.M004.NET.SSD.B050.G002"
  is_encrypted_base_block_storage_volume = true
}
resource "ncloud_server" "lb1_cand4" {
  subnet_no = "${ncloud_subnet.lb1_cand2.id}"
  server_image_product_code = "SW.VSVR.OS.LNX64.CNTOS.0703.B050"
  server_product_code = "SVR.VSVR.HICPU.C002.M004.NET.SSD.B050.G002"
}

resource "ncloud_lb_listener" "test" {
  load_balancer_no = ncloud_lb.cand1.load_balancer_no
  protocol = "HTTP"
  port = 80
  target_group_no = ncloud_lb_target_group.cand1.target_group_no
}

resource "ncloud_lb_target_group" "cand1" {
  protocol = "HTTP"
  vpc_no   = "${ncloud_vpc.cand2.id}"
  target_type = "VSVR"
  port = "8080"
  description = "lbtargetgroup"
  health_check {
    protocol = "HTTP"
    http_method = "GET"
    port = 8080
    url_path = "/"
    cycle = 30
    up_threshold = 2
    down_threshold = 2
  }
  algorithm_type = "RR"
}


resource "ncloud_subnet" "lb1_cand1" {
  network_acl_no = "${ncloud_vpc.cand2.default_network_acl_no}"
  subnet         = "10.1.1.0/24"
  subnet_type    = "PRIVATE"
  vpc_no         = "${ncloud_vpc.cand2.id}"
  zone           = "KR-2"
  usage_type     = "LOADB"
}
resource "ncloud_lb" "cand1" {
  subnet_no_list = [ncloud_subnet.lb1_cand1.subnet_no]
  type           = "APPLICATION"
}

resource "ncloud_lb_target_group_attachment" "cand1" {
  target_group_no = "${ncloud_lb_target_group.cand1.target_group_no}"
  target_no_list  = [ncloud_server.lb1_cand1.instance_no, ncloud_server.lb1_cand2.instance_no]
}