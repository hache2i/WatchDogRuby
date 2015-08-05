var WD= {};

WD.initialize = function(){
  WD.Bus = new WD.BusConst();
  if ($("#discover-page").length) WD.initializeDiscoverPage();
  if ($("#common-folders-page").length) WD.initializeCommonFoldersPage();
  if ($("#pending-files-page").length) WD.initializePendingFilesPage();
  if ($("#changed-files-page").length) WD.initializeChangedFilesPage();
  if ($("#proposed-files-page").length) WD.initializeProposedFilesPage();
  if ($("#exec-log").length) WD.initializeExecLog();
};

WD.drawDiscoverUsers = function(data){

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
    $('#sortedIdsStrForChildFolders').val(for_files.join());
    $('#child-folders-form').submit();
  });
};

WD.initializeDiscoverPage = function(){
  WD.Backend.getDomainUsers(WD.drawDiscoverUsers);
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
  var filesView = WD.ReactClasses.PendingFiles;
  var countChange = WD.ReactClasses.CountChange;
  new WD.Files(filter, filesView, countChange, "pending-files-page");
};

WD.initializeChangedFilesPage = function(){
  var filter = { "pending": false };
  var filesView = WD.ReactClasses.ChangedFiles;
  var filesCount = WD.ReactClasses.FilesCount;
  new WD.Files(filter, filesView, filesCount, "changed-files-page");
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

WD.sendChangePermissions = function(){
  var files = WD.colectFilesFromView();
  WD.Backend.newChangePermissions(files);
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
