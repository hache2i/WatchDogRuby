var WD= {};

WD.initialize = function(){
  if ($("#new-files-page").length) WD.initializeNewFilesPage();
  if ($("#proposed-files-page").length) WD.initializeProposedFilesPage();
  if ($("#files-changed-page").length) WD.initializeFilesChangedPage();
};

WD.initializeProposedFilesPage = function(){
  $("#change-permissions-btn").click(function(){
    $(this).spin(APP.spinOpts);
    WD.sendChangePermissions();
  });
}

WD.initializeFilesChangedPage = function(){
  console.log("going for changes");
  $.ajax({
    type: "GET",
    url: "/domain/changed",
    success: WD.drawChanged,
    error: function(){
      console.log("error getting changed files");
    }
  });
};

WD.drawChanged = function(data){
  console.log("changes fetched");
  var body = $("#files tbody");
  data.forEach(function(item){
    var row = $("<tr>");
    var title = $("<td>");
    title.html(item.title);
    row.append(title);
    var path = $("<td>");
    path.html(item.path);
    row.append(path);
    var oldOwner = $("<td>");
    oldOwner.html(item.oldOwner);
    row.append(oldOwner);
    var newOwner = $("<td>");
    newOwner.html(item.newOwner);
    row.append(newOwner);
    var id = $("<td>");
    id.html(item.fileId);
    row.append(id);
    var parentId = $("<td>");
    parentId.html(item.parentId);
    row.append(parentId);
    body.append(row);
  });
};

WD.initializeNewFilesPage = function(){
  $("#change-permissions-btn").click(function(){
    $(this).spin(APP.spinOpts);
    WD.sendChangePermissions();
  });
};

WD.sendChangePermissions = function(){
  var files = WD.colectFilesFromView();
  var params = { files: JSON.stringify(files) };
  $.ajax({
    type: "POST",
    url: "/domain/new-change-permissions",
    data: params,
    success: function(data){
      window.location = "/domain/changed-page";
    },
    error: function(){
      console.log("error changing permissions");
    }
  });
};

WD.colectFilesFromView = function(){
  var files = [];
  $(".file-record").each(function(){
    var file = {
      id: $(this).data("id"),
      fileId: $(this).data("fileid"),
      oldOwner: $(this).data("oldowner"),
      newOwner: $(this).data("newowner"),
      parent: $(this).data("parent"),
    }
    files.push(file)
  });
  return files;
};

$(function() {
  WD.initialize();
});
