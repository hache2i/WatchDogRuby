var WS= {};

WS.initialize = function(){
  if ($("#new-files-page").length) WS.initializeNewFilesPage();
};

WS.initializeNewFilesPage = function(){
  $("#change-permissions-btn").click(WS.sendChangePermissions);
};

WS.sendChangePermissions = function(){
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
  console.log(files);
  $.post(
    "/domain/new-change-permissions",
    { files: files },
    function(){
      console.log("yeah");
    },
    function(){
      console.log("fuck");
    }
  );
};

$(function() {
  WS.initialize();
});
