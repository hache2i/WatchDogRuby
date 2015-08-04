(function(ns){

  ns.ReactClasses = ns.ReactClasses || {};

  ns.ReactClasses.Header = React.createClass({displayName: 'Header',
    render: function(){
      return (
        React.createElement('div', { className: "page-header" }, this.props.title)
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
            React.createElement("td", {}, "Titulo"),
            React.createElement("td", {}, "Path"),
            React.createElement("td", {}, "Antiguo Propietario"),
            React.createElement("td", {}, "Nuevo Propietario"),
            React.createElement("td", {}, "")
          )
        ),
        React.createElement("tbody", {}, filesNodes)
      );
      var moreBtn = React.createElement("a", { onClick: this.props.moreHandler }, "Más");
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
            React.createElement("td", {}, "Titulo"),
            React.createElement("td", {}, "Path"),
            React.createElement("td", {}, "Antiguo Propietario"),
            React.createElement("td", {}, "Nuevo Propietario"),
            React.createElement("td", {}, "")
          )
        ),
        React.createElement("tbody", {}, filesNodes)
      );
      var moreBtn = React.createElement("a", { onClick: this.props.moreHandler }, "Más");
      return React.createElement("div", {}, filesTable, moreBtn);
    }
  });

  return ns;

}( WD || {} ));