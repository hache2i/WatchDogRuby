(function(ns){

    ns.Backend = ns.Backend || {};

    ns.Backend.getPendingFiles = function(from){
        $.ajax({
            type: "POST",
            url: "/domain/pending/files",
            data: { from: from },
            success: function(data){
                WD.Bus.send("pending-files-fetched", data);
            },
            error: function(){
                alert("Error obteniendo la cuenta de pendientes");
            }
        });
    };

    ns.Backend.getPendingFilesCount = function(){
        $.ajax({
            type: "GET",
            url: "/domain/pending/count",
            success: function(data){
                WD.Bus.send("pending-files-summary-fetched", data);
            },
            error: function(){
                alert("Error obteniendo la cuenta de pendientes");
            }
        });
    };

    ns.Backend.changeAllPendingPermissions = function(){
        $.ajax({
            type: "POST",
            url: "/domain/pending/change/all",
            success: function(data){
                WD.Bus.send("pending-files-change-all-process-started");
            },
            error: function(){
                alert("Error cambiando los permisos para todos los ficheros pendientes")
            }
        });
    };

    ns.Backend.changePermission = function(permissionId){
        $.ajax({
            type: "POST",
            url: "/domain/pending/change",
            data: { permissionId: permissionId },
            success: function(data){
                WD.Bus.send("pending-file-permission-changed");
            },
            error: function(){
                alert("Error cambiando los permisos para el fichero");
            }
        });
    };

    return ns;

}( WD || {} ));