var app = angular.module("customers");
app.controller("CustomerDetailController", [
          "$scope", "$http", "$routeParams", "$resource", "$uibModal",
  function($scope, $http, $routeParams, $resource, uibModal){
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
              $scope.alert = {
                type: "success",
                message: "Customer successfully saved."
              };
            },
            function(data){
              $scope.alert = {
                type: "danger",
                message: "Customer couldn't be saved"
              }
            }
          );

          $scope.closeAlert = function(index){
            $scope.alert = undefined;
          }

          $scope.deactivate = function(){
            var modalInstance = $uibModal.open({
              templateUrl: 'confirm_deactivate.html',
              controller: 'ConfirmDeactivateController'
            });

            modalInstance.result.then(function(){
              $scope.alert = {
                type: "success",
                message: "Customer deactivated"
              }
            }, function(reason){
              $scope.alert = {
                type: "warning",
                message: "Customer still active"
              }
            });
          }
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
