(function(ns){

  ns.Files = function(aFilter, Files, FilesCount, mountPoint){
    var _summary = { count: 0 };
    var index = 0;
    var _files = [];
    var _users = [];
    var _filter = aFilter;

    var _usersWithFilesFetched = function(data){
      _users = data;
      renderEverything();
    };

    var _filesFetched = function(data){
      if (index == 0) _files = [];
      data.forEach(function(newFile){
        _files.push(newFile);
      });
      index = index + data.length;
      renderEverything();
    };

    var _filesSummaryFetched = function(data){
      _summary = data;
      renderEverything();
    };

    var renderEverything = function(){
      React.render(
        React.createElement(Page, { summary: _summary, files: _files, users: _users, getMore: getMore }),
        document.getElementById(mountPoint)
      );
    };

    var changePermissions = function(){
      WD.Backend.changeAllPendingPermissions(_filter);
    };

    var _filterBy = function(field, value){
      if (value.length == 0){
        delete _filter[field];
      }else{
        _filter[field] = value;
      }
      index = 0;
      WD.Backend.getFilesCount(_filter);
      WD.Backend.getFiles(index, _filter);
    };

    var getMore = function(){
     WD.Backend.getFiles(index, _filter);
    };

    var Page = React.createClass({displayName: 'Page', 
      render: function(){
        return (
          React.createElement('div', {className: "page"},
            React.createElement(WD.ReactClasses.Header, { title: "Ficheros Pendientes" }),
            React.createElement(WD.ReactClasses.FilesFilter, { users: this.props.users, filterBy: _filterBy, count: this.props.summary.count, changePermissions: changePermissions, filesCount: FilesCount }),
            React.createElement(Files, { files: this.props.files, moreHandler: this.props.getMore })
          )
        );
      }
    });

    WD.Bus.subscribe("users-pending-files-fetched", _usersWithFilesFetched);
    WD.Bus.subscribe("pending-files-fetched", _filesFetched);
    WD.Bus.subscribe("pending-files-summary-fetched", _filesSummaryFetched);
    WD.Bus.subscribe("pending-files-change-all-process-started", function(){
      alert("procesando cambio de permisos para todos los fichero pendientes");
    });

    renderEverything();
    WD.Backend.getUsersWithFiles(_filter);
    WD.Backend.getFilesCount(_filter);
    WD.Backend.getFiles(index, _filter);
  };

  return ns;

}( WD || {} ));