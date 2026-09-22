-- Lo que se lanza al entrar en la sesión. Solo una vez: al recargar la
-- configuración no se vuelve a lanzar nada (para eso está Super+Shift+R).

local HOME = os.getenv("HOME")

hl.on("hyprland.start", function()

    -- Llavero del sistema: sin esto las apps no pueden guardar contraseñas
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets,pkcs11,ssh")
    -- Ventana que pide la contraseña cuando algo necesita permisos de root
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

    -- Fondo, barra y notificaciones
    hl.exec_cmd(HOME .. "/.config/hypr/scripts/fondo --restaurar")
    hl.exec_cmd(HOME .. "/.config/waybar/lanzar")
    hl.exec_cmd("dunst")

    -- Bloqueo y apagado de pantallas por inactividad (hypridle.conf)
    hl.exec_cmd("hypridle")

    -- Historial del portapapeles: guarda todo lo que se copia, texto e imágenes
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- El tema GTK, las fuentes y el cursor de gtk-3.0/settings.ini pasados
    -- a gsettings, que es de donde los leen las apps GTK en Wayland
    hl.exec_cmd(HOME .. "/.config/i3/scripts/import-gsettings")

    -- El cambiador de ventanas de Alt+Tab, esperando con el panel hecho para
    -- que salga al momento (hypr/scripts/alternador)
    hl.exec_cmd(HOME .. "/.config/hypr/scripts/alternador")

    -- La tarjeta de música del escritorio: siempre en marcha, igual que en
    -- i3. Ella sola se esconde cuando le pasa una ventana por encima
    hl.exec_cmd(HOME .. "/.config/i3/scripts/musica-escritorio")

    -- Programas con arranque automático (~/.config/autostart)
    hl.exec_cmd("dex --autostart --environment Hyprland")
    -- Carpetas de ~/Aplicaciones y menú al día
    hl.exec_cmd(HOME .. "/dotfiles/extra/organizar-apps -q")
end)
