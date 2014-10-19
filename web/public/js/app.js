var WS= {};

WS.initialize = function(){
  if ($("#new-files-page").length) WS.initializeNewFilesPage();
};

WS.initializeNewFilesPage = function(){
  $("#change-permissions-btn").click(WS.sendChangePermissions);
};

WS.sendChangePermissions = function(){
  var files = WS.colectFilesFromView();
  var params = { files: JSON.stringify(files) };
  $.ajax({
    type: "POST",
    url: "/domain/new-change-permissions",
    data: params,
    success: function(data){
      console.log("yeah");
    },
    error: function(){
      console.log("fuck");
    }
  });
};

WS.colectFilesFromView = function(){
  var files = [];
  $(".file-record").each(function(){
    var file = {
      id: $(this).data("id"),
      title: $(this).data("title"),
      owner: $(this).data("owner"),
      parent: $(this).data("parent")
    }
    files.push(file)
  });
  return files;
};

$(function() {
  WS.initialize();
});
