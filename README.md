# DepenJect

## Description
A self-educational iOS experiment to illustrate the difference between Singleton and Dependency Injection.

## Frameworks
Swift - SwiftUI - Combine

## Architecture
MVVM

## Remarks
Singleton issues:
1. They are Global and can be accessed anywhere in our app which is not desired.
2. They can't swap out dependencies.
3. They can't customize the init.

Dependency Injection can fix the above issues:
1. The only classes that have access to our service will be ones that we are injection our service to them.
2. It was by customising the init of our service in our Preview.
3. By introducing protocol, we can fix the issue and swap between ProductionDataService and MockDataService.
 
