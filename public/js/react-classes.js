(function(ns){

  ns.ReactClasses = ns.ReactClasses || {};

  ns.ReactClasses.Header = React.createClass({displayName: 'Header',
    render: function(){
      return (
        React.createElement('div', { className: "page-header" }, 
          React.createElement('h1', {}, this.props.title)
        )
      );
    }
  });

  ns.ReactClasses.ChangeLink = React.createClass({displayName: 'ChangeLink',
    handleClick: function(){
      WD.Backend.changePermission(this.props.permissionId);
    },
    render: function(){
      return React.createElement("a", { onClick: this.handleClick }, "Cambiar");
    }
  });

  ns.ReactClasses.PendingFiles = React.createClass({displayName: 'Files',
    render: function(){
      var filesNodes = this.props.files.map(function(file){
        return React.createElement("tr", {},
          React.createElement("td", {}, file.title),
          React.createElement("td", {}, file.path),
          React.createElement("td", {}, file.oldOwner),
          React.createElement("td", {}, file.newOwner),
          React.createElement("td", {}, 
            React.createElement(ns.ReactClasses.ChangeLink, { permissionId: file._id })
          )
        );
      });
      var filesTable = React.createElement("table", { className: "table table-striped", id: "files" },
        React.createElement("thead", {},
          React.createElement("tr", {},
            React.createElement("th", {}, "Titulo"),
            React.createElement("th", {}, "Path"),
            React.createElement("th", {}, "Antiguo Propietario"),
            React.createElement("th", {}, "Nuevo Propietario"),
            React.createElement("th", {}, "")
          )
        ),
        React.createElement("tbody", {}, filesNodes)
      );
      var moreBtn = React.createElement("div", { className: "wd-btn", onClick: this.props.moreHandler }, 
        React.createElement("h4", {}, "Más")
      );
      return React.createElement("div", {}, filesTable, moreBtn);
    }
  });

  ns.ReactClasses.ChangedFiles = React.createClass({displayName: 'Files',
    render: function(){
      var filesNodes = this.props.files.map(function(file){
        return React.createElement("tr", {},
          React.createElement("td", {}, file.title),
          React.createElement("td", {}, file.path),
          React.createElement("td", {}, file.oldOwner),
          React.createElement("td", {}, file.newOwner),
          React.createElement("td", {}, "")
        );
      });
      var filesTable = React.createElement("table", { className: "table table-striped", id: "files" },
        React.createElement("thead", {},
          React.createElement("tr", {},
            React.createElement("th", {}, "Titulo"),
            React.createElement("th", {}, "Path"),
            React.createElement("th", {}, "Antiguo Propietario"),
            React.createElement("th", {}, "Nuevo Propietario"),
            React.createElement("th", {}, "")
          )
        ),
        React.createElement("tbody", {}, filesNodes)
      );
      var moreBtn = React.createElement("div", { className: "wd-btn", onClick: this.props.moreHandler }, 
        React.createElement("h4", {}, "Más")
      );
      return React.createElement("div", {}, filesTable, moreBtn);
    }
  });

  ns.ReactClasses.FilesFilter = React.createClass({ displayName: "Filter",
    getInitialState: function () {
      return {
        users: []
      }
    },
    handleMultiChange: function (users) {
      this.setState({ users: users });
      this.props.filterBy("oldOwner", users);
    },
    handleInputChange: function(){
      this.props.filterBy("title", this.refs.titleSearch.getDOMNode().value.trim());
    },
    render: function(){
      var SelectBox = React.createFactory(WD.SelectBox);
      var option = React.createElement.bind(null,'option')
      var options = this.props.users.map(function(user){
        return option({ value: user}, user);
      });
      var selectConfig = {
        label: "Usuarios",
        onChange: this.handleMultiChange,
        value: this.state.users,
        multiple: true
      };
      return React.createElement("div", { className: "pending-filter row" },
        React.createElement("div", { className: "span3"}, SelectBox(selectConfig, options)),
        React.createElement("div", { className: "span3"},
          React.createElement("input", { onChange: this.handleInputChange, className: "filter-input", ref: "titleSearch", placeholder: "Título" })
        ),
        React.createElement("div", { className: "span3"},
          React.createElement(this.props.filesCount, { count: this.props.count, changePermissions: this.props.changePermissions })
        )
      )
    }
  });

  ns.ReactClasses.FilesCount = React.createClass({displayName: "Count",
    render: function(){
      return React.createElement('div', { className: "wd-files-count" },
        React.createElement('span', { className: "files-count" }, this.props.count), " ficheros"
      )
    }
  });

  ns.ReactClasses.CountChange = React.createClass({displayName: "Count",
    render: function(){
      return React.createElement('div', { className: "wd-btn wd-btn-change-ownership", onClick: this.props.changePermissions },
        "Cambiar ", React.createElement('span', { className: "files-count" }, this.props.count), " ficheros"
      )
    }
  });

  return ns;

}( WD || {} ));