/*Compile LESS task*/

module.exports = function(grunt, data){

  return {
    dev: {
       options: {
          paths: ["app/assets"]
       },
       files: { "app/assets/stylesheets/style.css": "app/assets/stylesheets/style.less"}
    },
    dist: {
       options: {
          paths: ["app/assets"]
       },
       files: [
        {"app/assets/stylesheets/style.css": "app/assets/stylesheets/style.less"}
      ]
    }
  };
};
