(function(ns){

  ns.Files = function(aFilter, Files, mountPoint){
    var SelectBox = React.createFactory(WD.SelectBox);

    var div = React.createElement.bind(null,'div')
    var option = React.createElement.bind(null,'option')
    var h1 = React.createElement.bind(null,'h1')

    var _summary = { count: 0 };
    var index = 0;
    var _files = [];
    var _users = [];
    var _filter = aFilter;

    var _usersWithPendingFilesFetched = function(data){
      _users = data;
      renderEverything();
    };

    var _pendingFilesFetched = function(data){
      if (index == 0) _files = [];
      data.forEach(function(newFile){
        _files.push(newFile);
      });
      index = index + data.length;
      renderEverything();
    };

    var _pendingFilesSummaryFetched = function(data){
      _summary = data;
      renderEverything();
    };

    var renderEverything = function(){
      React.render(
        React.createElement(Page, { summary: _summary, files: _files, users: _users }),
        document.getElementById(mountPoint)
      );
    };

    var FilesCount = React.createClass({displayName: "Count",
      handleChangePermissions: function(){
        WD.Backend.changeAllPendingPermissions(_filter);
      },
      render: function(){
        return React.createElement('div', { className: "files-count-container" },
          React.createElement('span', null, "Total:"),
          React.createElement('span', null, this.props.count),
          React.createElement('a', { onClick: this.handleChangePermissions }, "Change permissions")
        )
      }
    });

    var ChangeLink = React.createClass({displayName: 'ChangeLink',
      handleClick: function(){
        WD.Backend.changePermission(this.props.permissionId);
      },
      render: function(){
        return React.createElement("a", { onClick: this.handleClick }, "Cambiar");
      }
    });

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

    var FilesFilter = React.createClass({ displayName: "Filter",
      getInitialState: function () {
        return {
          colors: []
        }
      },
      handleMultiChange: function (colors) {
        this.setState({ colors: colors });
        _filterBy("oldOwner", colors);
      },
      render: function(){
        var options = this.props.users.map(function(user){
          return option({ value: user}, user);
        });
        return React.createElement("div", { className: "pending-filter" },
          SelectBox(
            {
              label: "Favorite Colors",
              onChange: this.handleMultiChange,
              value: this.state.colors,
              multiple: true
            },
            options
          )
        )
      }
    });

    var getMore = function(){
     WD.Backend.getFiles(index, _filter);
    };

    var Page = React.createClass({displayName: 'Page', 
      render: function(){
        return (
          React.createElement('div', {className: "page"},
            React.createElement(WD.ReactClasses.Header, { title: "Ficheros Pendientes" }),
            React.createElement(FilesFilter, { users: this.props.users }),
            React.createElement(FilesCount, { count: this.props.summary.count }),
            React.createElement(Files, { files: this.props.files, moreHandler: getMore })
          )
        );
      }
    });

    WD.Bus.subscribe("users-pending-files-fetched", _usersWithPendingFilesFetched);
    WD.Bus.subscribe("pending-files-fetched", _pendingFilesFetched);
    WD.Bus.subscribe("pending-files-summary-fetched", _pendingFilesSummaryFetched);
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