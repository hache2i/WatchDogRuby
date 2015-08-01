(function(ns){

    ns.Backend = ns.Backend || {};

    ns.Backend.getUsersWithPendingFiles = function(){
        $.ajax({
            type: "GET",
            url: "/domain/pending/files/users",
            success: function(data){
                WD.Bus.send("users-pending-files-fetched", data);
            },
            error: function(){
                alert("Error obteniendo los usuarios con ficheros pendientes");
            }
        });
    };

    ns.Backend.getPendingFiles = function(from, filter){
        $.ajax({
            type: "POST",
            url: "/domain/pending/files",
            data: { from: from, filter: filter },
            success: function(data){
                WD.Bus.send("pending-files-fetched", data);
            },
            error: function(){
                alert("Error obteniendo los ficheros pendientes");
            }
        });
    };

    ns.Backend.getPendingFilesCount = function(filter){
        $.ajax({
            type: "GET",
            url: "/domain/pending/count",
            data: { filter: filter },
            success: function(data){
                WD.Bus.send("pending-files-summary-fetched", data);
            },
            error: function(){
                alert("Error obteniendo la cuenta de pendientes");
            }
        });
    };

    ns.Backend.changeAllPendingPermissions = function(filter){
        $.ajax({
            type: "POST",
            url: "/domain/pending/change/all",
            data: { filter: filter },
            success: function(data){
                console.log(data);
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