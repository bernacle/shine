var app = angular.module("customers");
app.controller("CustomerDetailController", [
          "$scope", "$http", "$routeParams", "$resource",
  function($scope, $http, $routeParams, $resource){
    $scope.customerId = $routeParams.id;
    var Customer = $resource('/customers/:customerId.json',
                             {"customerId": "@customer_id"},
                             {"save": {"method": "PUT"}});
    $scope.customer = Customer.get({ "customerId": $scope.customerId});
    $scope.save = function(){
        if($scope.form.$valid){
          $scope.customer.$save(
            function(){
              $scope.form.$setPristine();
              $scope.form.$setUntouched();
              alert("Save Successful!");
            },
            function(){
              alert("Save Failed :(")
            }
          );
        }
    }

    $http.get(
      "/customers/" + $scope.customerId + ".json"
    ).then(function(response){
      $scope.customer = response.data;
    },function(response){
      alert("There was a problem: " + response.status);
    });
  }
]);
