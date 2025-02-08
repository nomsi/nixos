# I wanted to put this here and include it in the main configuration file
# So we can see what I did and how it works, I guess?
{ config, pkgs, ... }:
{
  # Bootloader.
  boot = {
    # Technically we can just use boot.loader.systemd etc here but, it 
    # needed to be further defined out.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Kernel parameters to tell the bootloader we have IOMMU on
    kernelParams = [ "amd_iommu=on" ];

    # Blacklist the GPU module from loading on boot.
    blacklistedKernelModules = [ "nvidia" "nouveau" ];

    # Setup the kernel modules we need for VFIO
    kernelModules = [ "kvm-amd" "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];

    # This post boot command basically says on boot, modprobe these IDs which is why we
    # blacklist. (I have two identical cards)
    postBootCommands = ''
        DEVS="0000:04:00.0 0000:04:00.1 0000:04:00.2 0000:04:00.3"

        for DEV in $DEVS; do
          echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
        done
        modprobe -i vfio-pci
    '';
  };
}