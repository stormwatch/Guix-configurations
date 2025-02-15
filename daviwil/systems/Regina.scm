(define-module (daviwil systems Regina)
  #:use-module (daviwil utils)
  #:use-module (daviwil systems base)
  #:use-module (daviwil systems common)
  #:use-module (daviwil home-services audio)
  #:use-module (daviwil home-services games)
  #:use-module (daviwil home-services video)
  #:use-module (daviwil home-services finance)
  #:use-module (daviwil home-services streaming)
  #:use-module (gnu)
  #:use-module (gnu home)
  #:use-module (gnu home services sound)
  #:use-module (gnu packages file-systems)
  #:use-module (gnu services)
  #:use-module (gnu services docker)
  #:use-module (gnu system)
  #:use-module (gnu system uuid)
  #:use-module (gnu system file-systems)
  #:use-module (nongnu packages linux))

(system-config
 #:home
 (home-environment
  (packages (gather-manifest-packages '(mail)))
  (services (cons* (service home-pipewire-service-type)
                   (service home-video-service-type)
                   (service home-audio-service-type)
                   (service home-finance-service-type)
                   (service home-streaming-service-type)
                   (service home-games-service-type)
                   common-home-services)))

 #:system
 (operating-system
   (host-name "Regina")
   (firmware (list linux-firmware))
   (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets '("/boot/efi"))
                (keyboard-layout keyboard-layout)))
   (file-systems (cons*
                  (file-system
                   (device (file-system-label "root"))
                   (mount-point "/")
                   (type "ext4"))
                  (file-system
                   (device (file-system-label "EFI"))
                   (mount-point "/boot/efi")
                   (type "vfat"))
                  (file-system
                   (device (file-system-label "data0"))
                   (mount-point "/mnt/data")
                   (type "btrfs")
		   (flags '(no-atime))
		   (options "subvol=data,autodefrag,compress,space_cache=v2")
		   (mount-may-fail? #t))
                  %base-file-systems))
   (services (list
              (service oci-container-service-type
                       (list
                        (oci-container-configuration
                         (image "jellyfin/jellyfin")
                         (provision "jellyfin")
                         (network "host")
                         (ports
                          '(("8096" . "8096")))
                         (volumes
                          '("jellyfin-config:/config"
                            "jellyfin-cache:/cache"
                            "/mnt/data:/media")))))))))
