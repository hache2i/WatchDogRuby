var WD= {};

WD.initialize = function(){
  if ($("#new-files-page").length) WD.initializeNewFilesPage();
  if ($("#files-changed-page").length) WD.initializeFilesChangedPage();
};

WD.initializeFilesChangedPage = function(){
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
  var body = $("#files tbody");
  data.forEach(function(item){
    var row = $("<tr>");
    var id = $("<td>");
    id.html(item.fileId);
    row.append(id);
    var title = $("<td>");
    title.html(item.title);
    row.append(title);
    var oldOwner = $("<td>");
    oldOwner.html(item.oldOwner);
    row.append(oldOwner);
    var newOwner = $("<td>");
    newOwner.html(item.newOwner);
    row.append(newOwner);
    var parentId = $("<td>");
    parentId.html(item.parentId);
    row.append(parentId);
    body.append(row);
  });
};

WD.initializeNewFilesPage = function(){
  $("#change-permissions-btn").click(WD.sendChangePermissions);
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
      title: $(this).data("title"),
      owner: $(this).data("owner"),
      parent: $(this).data("parent")
    }
    files.push(file)
  });
  return files;
};

$(function() {
  WD.initialize();
});
