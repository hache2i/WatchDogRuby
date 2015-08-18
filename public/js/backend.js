(function(ns){

    ns.Backend = ns.Backend || {};

    ns.Backend.getDetails = function(itemId, callback){
        $.ajax({
            type: "POST",
            url: "/api/details",
            data: { itemId: itemId },
            success: function(data){
                console.log(data);
                callback(data);
            },
            error: function(){
                console.log("Error obteniendo detalles");
            }
        });
    }

    ns.Backend.getCommonFolders = function(){
        $.ajax({
            type: "GET",
            url: "/api/common-folders",
            success: function(data){
                WD.Bus.send("common-folders-fetched", data);
            },
            error: function(){
                alert("Error obteniendo carpetas comunes");
            }
        });
    };

    ns.Backend.getDomainUsers = function(callback){
        $.ajax({
            type: "GET",
            url: "/api/users",
            success: callback,
            error: function(){
              console.log("error getting changed files");
            }
          });
    };

    ns.Backend.newChangePermissions = function(files){
      var params = { files: JSON.stringify(files) };
      $.ajax({
        type: "POST",
        url: "/api/new-change-permissions",
        data: params,
        success: function(data){
          window.location = "/domain";
        },
        error: function(){
          console.log("error changing permissions");
        }
      });
    };

    ns.Backend.getUsersWithFiles = function(filter){
        $.ajax({
            type: "GET",
            url: "/api/files/users",
            data: { filter: filter },
            success: function(data){
                WD.Bus.send("users-pending-files-fetched", data);
            },
            error: function(){
                alert("Error obteniendo los usuarios con ficheros pendientes");
            }
        });
    };

    ns.Backend.getFiles = function(from, filter){
        $.ajax({
            type: "POST",
            url: "/api/files/list",
            data: { from: from, filter: filter },
            success: function(data){
                WD.Bus.send("pending-files-fetched", data);
            },
            error: function(){
                alert("Error obteniendo los ficheros pendientes");
            }
        });
    };

    ns.Backend.getFilesCount = function(filter){
        $.ajax({
            type: "GET",
            url: "/api/files/count",
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
            url: "/api/pending/change/all",
            data: { filter: filter },
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
            url: "/api/pending/change",
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