% ==============================================
% PARTE 1: CATALOGO DE VEHICULOS
% ==============================================

% Definicion del catalogo
vehicle(toyota, rav4, suv, 28000, 2022).
vehicle(toyota, corolla, sedan, 22000, 2023).
vehicle(toyota, tacoma, pickup, 35000, 2021).
vehicle(ford, mustang, sport, 45000, 2023).
vehicle(ford, explorer, suv, 32000, 2022).
vehicle(ford, explorer, suv, 32000, 2012).
vehicle(ford, f150, pickup, 40000, 2023).
vehicle(bmw, x5, suv, 60000, 2021).
vehicle(bmw, x5, suv, 55000, 2019).
vehicle(bmw, serie3, sedan, 42000, 2022).
vehicle(bmw, z4, sport, 52000, 2023).
vehicle(chevrolet, camaro, sport, 38000, 2022).
vehicle(chevrolet, silverado, pickup, 42000, 2023).
vehicle(honda, civic, sedan, 24000, 2022).

% ==============================================
% PARTE 2: CONSULTAS BASICAS Y FILTROS
% ==============================================

% Filtra vehículos por tipo, marca y presupuesto máximo
filter_by_type_and_budget(Brand, Type, BudgetMax, Reference) :-
    vehicle(Brand, Reference, Type, Price, _),
    Price =< BudgetMax.

% Filtra vehículos por tipo y presupuesto máximo
filter_by_type_and_budget(Type, BudgetMax, Reference) :-
    vehicle(_, Reference, Type, Price, _),
    Price =< BudgetMax.

% Listar vehiculos por marca usando findall/3
list_by_brand(Brand, Vehicles) :-
    findall(Reference, vehicle(Brand, Reference, _, _, _), Vehicles).

% Listar vehiculos por tipo y año usando bagof/3
group_by_brand_bagof(Brand, Grouped) :-
    bagof((Type, Year, Reference),
          (vehicle(Brand, Reference, Type, _, Year)),
          Grouped).

% Listar vehiculos agrupados por marca y tipo usando bagof/3
group_by_brand_and_type(Grouped) :-
    bagof((Brand, Type, Reference),
          vehicle(Brand, Reference, Type, _, _),
          Grouped).

% ==============================================
% PARTE 3: GENERACION DE REPORTES
% ==============================================

% Predicado principal para generar reportes
generate_report(Brand, Type, Budget, Result) :-
    findall((Reference, Price, Year),
            (vehicle(Brand, Reference, Type, Price, Year),
             Price =< Budget),
            Vehicles),
    calculate_total_value(Vehicles, Total),
    (Total =< 1000000 ->
        Result = [vehicles:Vehicles, total_value:Total]
    ;
        adjust_inventory(Vehicles, AdjustedVehicles, AdjustedTotal),
        Result = [vehicles:AdjustedVehicles, total_value:AdjustedTotal,
                 note:'Ajustado por presupuesto maximo']
    ).

% Calcular el valor total del inventario
calculate_total_value(Vehicles, Total) :-
    findall(Price, member((_, Price, _), Vehicles), Prices),
    sum_list(Prices, Total).

% Ajustar el inventario cuando se excede el presupuesto maximo
adjust_inventory(Vehicles, AdjustedVehicles, AdjustedTotal) :-
    sort_by_price(Vehicles, Sorted),
    accumulate_vehicles(Sorted, 1000000, AdjustedVehicles, 0, AdjustedTotal).

% Ordenar vehiculos por precio (ascendente)
sort_by_price(Vehicles, Sorted) :-
    predsort(compare_prices, Vehicles, Sorted).

compare_prices(Order, (_, P1, _), (_, P2, _)) :-
    compare(Order, P1, P2).

% Acumular vehiculos hasta alcanzar el presupuesto maximo
accumulate_vehicles([], _, [], Total, Total).
accumulate_vehicles([(Ref, Price, Year)|Rest], Budget, [(Ref, Price, Year)|Acc], Current, Total) :-
    NewCurrent is Current + Price,
    NewCurrent =< Budget,
    accumulate_vehicles(Rest, Budget, Acc, NewCurrent, Total).
accumulate_vehicles([_|Rest], Budget, Acc, Current, Total) :-
    accumulate_vehicles(Rest, Budget, Acc, Current, Total).
