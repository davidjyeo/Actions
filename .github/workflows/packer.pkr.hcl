packer {
  required_plugins {
    windows-update = {
      version = "0.14.0"
      source = "github.com/rgl/windows-update"
    }
  }
}

source "azure-arm" "ws2019g1" {
  azure_tags = {
    App               = "CCK"
    BillingIdentifier = "9151"
    Created           = "Packer"
    Department        = "MRC"
    EnvironmentType   = "Pre Production"
    ManagedBy         = ""
    Owner             = ""
    ServiceName       = "Access VM"
  }
  client_id                         = "90c75960-f332-4d0b-9444-72f64094a93e"
  client_secret                     = "5O29l9JHRTQ5TEt~Y3.B_adJcJC8sQ.t_V"
  communicator                      = "winrm"
  image_offer                       = "WindowsServer"
  image_publisher                   = "MicrosoftWindowsServer"
  image_sku                         = "2019-DataCenter-smalldisk"
  # image_sku                         = "2022-datacenter-smalldisk-g2"
  # managed_image_name                = "GoldImageG1-${formatdate("YYYYMMDD", timestamp())}"

  shared_image_gallery_destination {
    subscription         = "d0f6eb41-3e86-48da-bc57-893eab20796f"
    resource_group       = "centrum-shared"
    gallery_name         = "centrum_sig"
    image_name           = "avm2019g1"
    image_version        = "${formatdate("DD.hh.mm", timestamp())}"
    replication_regions  = ["uksouth"] #, "regionB", "regionC"]
    storage_account_type = "Standard_LRS"
  }

  managed_image_name                = "GoldImageG1-${formatdate("hhmm", timestamp())}"
  managed_image_resource_group_name = "centrum-shared"
  os_type                           = "Windows"
  # os_disk_size_gb                   = 1024
  subscription_id                   = "d0f6eb41-3e86-48da-bc57-893eab20796f"
  location                          = "uksouth"
  temp_resource_group_name          = "centrum-packer-${formatdate("hhmm", timestamp())}"
  # temp_compute_name                 = "pkrvm-${formatdate("hhmm", timestamp())}"
  # temp_nic_name                     = "pkr-nic"
  vm_size                           = "Standard_B1ms"
  # vm_size                           = "Standard_D2as_v4"
  # vm_size                           = "${var.vm_size}"
  winrm_insecure                    = true
  winrm_timeout                     = "5m"
  winrm_use_ssl                     = true
  winrm_username                    = "localmgr"
  async_resourcegroup_delete        = true
}
# ####
# source "azure-arm" "ws2019g2" {
#   azure_tags = {
#     App               = "CCK"
#     BillingIdentifier = "9151"
#     Created           = "Packer"
#     Department        = "MRC"
#     EnvironmentType   = "Pre Production"
#     ManagedBy         = ""
#     Owner             = ""
#     ServiceName       = "Access VM"
#   }
#   client_id                         = "90c75960-f332-4d0b-9444-72f64094a93e"
#   client_secret                     = "5O29l9JHRTQ5TEt~Y3.B_adJcJC8sQ.t_V"
#   communicator                      = "winrm"
#   image_offer                       = "WindowsServer"
#   image_publisher                   = "MicrosoftWindowsServer"
#   image_sku                         = "2019-DataCenter-smalldisk-g2"
#   # image_sku                         = "2022-datacenter-smalldisk-g2"
#   # managed_image_name                = "GoldImageG2-${formatdate("YYYYMMDD", timestamp())}"

#   shared_image_gallery_destination {
#     subscription         = "d0f6eb41-3e86-48da-bc57-893eab20796f"
#     resource_group       = "centrum-shared"
#     gallery_name         = "centrum_sig"
#     image_name           = "avm2019g2"
#     image_version        = "${formatdate("DD.hh.mm", timestamp())}"
#     replication_regions  = ["uksouth"] #, "regionB", "regionC"]
#     storage_account_type = "Standard_LRS"
#   }

#   managed_image_name                = "GoldImageG2-${formatdate("hhmm", timestamp())}"
#   managed_image_resource_group_name = "centrum-shared"
#   os_type                           = "Windows"
#   # os_disk_size_gb                   = 1024
#   subscription_id                   = "d0f6eb41-3e86-48da-bc57-893eab20796f"
#   location                          = "uksouth"
#   temp_resource_group_name          = "centrum-packer-${formatdate("hhmm", timestamp())}"
#   # temp_compute_name                 = "pkrvm-${formatdate("hhmm", timestamp())}"
#   # temp_nic_name                     = "pkr-nic"
#   vm_size                           = "Standard_B1ms"
#   # vm_size                           = "Standard_D2as_v4"
#   # vm_size                           = "${var.vm_size}"
#   winrm_insecure                    = true
#   winrm_timeout                     = "5m"
#   winrm_use_ssl                     = true
#   winrm_username                    = "localmgr"
#   async_resourcegroup_delete        = true
# }
# ####

build {
  sources = [
    "source.azure-arm.ws2019g1" #,
    # "source.azure-arm.ws2019g2",
    ]

  provisioner "file" {
    source = "./scripts/unattend.xml"
    destination = "c:\\windows\\system32\\sysprep\\unattend.xml"
  }
  # provisioner "powershell" {
  #   inline = ["iex "\"& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI -EnablePSRemoting -AddExplorerContextMenu -Quiet\"]
  # }
  # provisioner "powershell" {
  #   inline = ["${var.install_ps}"]
  # }
  # provisioner "powershell" {
  #   inline = ["Get-NetFirewallRule -DisplayGroup 'Network Discovery' | Set-NetFirewallRule -Profile 'Private, Domain' -Enabled true"]
  # }
  provisioner "powershell" {
    inline = ["[System.Environment]::SetEnvironmentVariable('DepartmentalImage','CCK Access VMs',[System.EnvironmentVariableTarget]::Machine)"]
  }
  provisioner "powershell" {
    inline = ["[System.Environment]::SetEnvironmentVariable('ImageVersion','${formatdate("YYYY.MM.DD", timestamp())}',[System.EnvironmentVariableTarget]::Machine)"]
  }

  #######################
  ### Windows Restart ###
  #######################

  # provisioner "windows-restart" {}

  ########################
  ### Mandatory Script ###
  ########################

  # provisioner "powershell" {
  #   script = "./scripts/mandatory.ps1"
  # }

  # provisioner "powershell" {
  #   script = "./scripts/ps_install.ps1"
  # }

  ########################
  ### Hardening Script ###
  ########################

  #########################
  ### Compliance Script ###
  #########################

  ###########################
  ### Optimisation Script ###
  ###########################

  ###########################
  ### Departmental Script ###
  ###########################

  ######################
  ### Windows Update ###
  ######################

  # provisioner "windows-update" {
  #   search_criteria = "IsInstalled=0"
  #   filters = [
  #     "exclude:$_.Title -like '*Preview*'",
  #     "include:$true",
  #   ]
  # }

  ################
  ### Clean-Up ###
  ################

  # provisioner "powershell" {
  #   script = "./scripts/cleanup.ps1"
  # }

  ###############
  ### Sysprep ###
  ###############

  provisioner "powershell" {
    inline = [
      " Invoke-Expression (Invoke-WebRequest -uri 'https://raw.githubusercontent.com/DarwinJS/Undo-WinRMConfig/master/Undo-WinRMConfig.ps1')",
      "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit /mode:vm /unattend:$env:SystemRoot\\System32\\Sysprep\\unattend.xml",
      "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"]
  }
}
