var WD= {};

WD.initialize = function(){
  WD.Bus = new WD.BusConst();
  if ($("#discover-page").length) WD.initializeDiscoverPage();
  if ($("#common-folders-page").length) WD.initializeCommonFoldersPage();
  if ($("#pending-files-page").length) WD.initializePendingFilesPage();
  if ($("#changed-files-page").length) WD.initializeChangedFilesPage();
  if ($("#proposed-files-page").length) WD.initializeProposedFilesPage();
  if ($("#files-changed-page").length) WD.initializeFilesChangedPage();
  if ($("#exec-log").length) WD.initializeExecLog();
};

WD.initializeDiscoverPage = function(){
  $.ajax({
    type: "GET",
    url: "/domain/api/users",
    success: function(data){
      WD.buildUsersList($("#discover-container"));
      data.forEach(function(user){
        var userItem = $("<tr class='user'>");
        var td = $("<td id='userName'></td>");
        td.append(user.email);
        userItem.append(td);

        var selectBoxItem = $("<td>");
        var selectBox = $("<input type='checkbox' class='select_files' />");
        selectBox.attr("id", user.name);
        selectBox.attr("value", user.email);
        selectBoxItem.append(selectBox);
        userItem.append(selectBoxItem);

        $("#users-container").append(userItem);
      });
      var button = $("<button id='childFoldersBtn' class='btn btn-large btn-primary'>Descubrir</button>");
      $("#discover-container").append(button);

      $('#select_all').click(function(){
      checkboxes = $( "input[type='checkbox']" );
      for (var i = checkboxes.length - 1; i >= 0; i--) {
        $(checkboxes[i]).attr('checked', $(this).attr('checked')?$(this).attr('checked'):false);
      };
      });
      $("#childFoldersBtn").click(function(){
        $(this).spin(APP.spinOpts);
        var users = $('tbody').find($( "input:checked" ));
        var for_files = [];
        for (var i = users.length - 1; i >= 0; i--) {
          for_files.push(users[i].value);
        };
        console.log(for_files);
        $('#sortedIdsStrForChildFolders').val(for_files.join());
        $('#child-folders-form').submit();
      });
    },
    error: function(){
      console.log("error getting changed files");
    }
  });

};

WD.buildUsersList = function(container){
  var usersList = $("<table class='table table-striped users no_caducity' id='users'>");

  var header = $("<thead><tr><th>Email</th><th><input type='checkbox' id='select_all' /></th></tr></thead>")
  usersList.append(header);

  var body = $("<tbody id='users-container'>");
  usersList.append(body);

  container.append(usersList);
};

WD.initializeExecLog = function(){
  console.log("going for log records");
  var execLog = new WD.ExecutionLog();
};

WD.initializePendingFilesPage = function(){
  var filter = { "pending": true };
  var filesView = WD.ReactClasses.Files;
  new WD.Files(filter, filesView, "pending-files-page");
};

WD.initializeChangedFilesPage = function(){
  var filter = { "pending": false };
  var filesView = WD.ReactClasses.Files;
  new WD.Files(filter, filesView, "changed-files-page");
};

WD.initializeCommonFoldersPage = function(){
  new WD.CommonFolders();
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
