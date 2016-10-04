var app = angular.module('customers',['ngRoute', 'templates']);

app.controller("CustomerSearchController", [
          '$scope','$http', '$location',
  function($scope , $http, $location) {

    var page = 0;

    $scope.customers = [];
    $scope.search = function(searchTerm) {
      $scope.loading = true;
      if (searchTerm.length < 3) {
        return;
      }
      // ... rest of the function
      $http.get("/customers.json",
                { "params": { "keywords": searchTerm, "page": page } }
      ).success(
        function(data,status,headers,config) {
          $scope.customers = data;
          $scope.loading = false;
      }).error(
        function(data,status,headers,config) {
          $scope.loading = false;
          alert("There was a problem: " + status);
        });
    }

    $scope.previousPage = function() {
      if (page > 0) {
        page = page - 1;
        $scope.search($scope.keywords);
      }
    }
    $scope.nextPage = function() {
      page = page + 1;
      $scope.search($scope.keywords);
    }

    $scope.viewDetails = function(customer){
        $location.path("/" + customer.id);
    }
  }
]);

app.controller("CustomerDetailController", [
          "$scope", "$http", "$routeParams",
  function($scope, $http, $routeParams){
    var customerId = $routeParams.id;
    $scope.customer = {};

    $http.get(
      "/customers/" + customerId + ".json"
    ).then(function(response){
      $scope.customer = response.data;
    },function(response){
      alert("There was a problem: " + response.status);
    });
  }
]);

app.config(["$routeProvider", function($routeProvider){
  $routeProvider.when("/", {
    controller: "CustomerSearchController",
    templateUrl: "customer_search.html"
  }).when("/:id", {
    controller: "CustomerDetailController",
    templateUrl: "customer_detail.html"
  });
}]);
