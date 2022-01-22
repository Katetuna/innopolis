with 
cte1 as (
select count(seat_no) as seat_actual, flight_id
from bookings.boarding_passes
group by flight_id),
cte2 as (select bookings.flights.aircraft_code,bookings.flights.flight_id as flight_id , count(bookings.seats.seat_no) as seat_all,
bookings.flights.departure_airport as departure_airport, bookings.flights.actual_departure  as actual_departure
from bookings.flights, bookings.seats
where bookings.flights.aircraft_code = bookings.seats.aircraft_code 
group by bookings.flights.aircraft_code, bookings.flights.flight_id
)
select cte2.departure_airport, to_char(cte2.actual_departure,'dd.mm.yyyy'), cte1.seat_actual,cte2.seat_all, cte1.flight_id,
(cte2.seat_all - cte1.seat_actual)*100/cte2.seat_all as percents, sum(cte1.seat_actual) over (partition by cte2.departure_airport,
to_char(cte2.actual_departure,'dd.mm.yyyy')
order by cte2.departure_airport, cte2.actual_departure)
from cte1 
join cte2 on cte1.flight_id = cte2.flight_id

with cte1 as (
select count(status) as real_flights, aircraft_code
from bookings.flights
where status not in ('Cancelled', 'Scheduled')
group by aircraft_code),
cte2 as (
select COUNT(flight_no) over () as all_flights, aircraft_code 
from bookings.flights
where status not in ('Cancelled', 'Scheduled'))
select distinct cte1.aircraft_code,  cte2.all_flights, cte1.real_flights, (cte1.real_flights*100/cte2.all_flights)::numeric as percents
from cte1
join cte2 using (aircraft_code)

select bookings.tickets.book_ref, bookings.boarding_passes.boarding_no
from bookings.tickets
left join bookings.boarding_passes  using (ticket_no) 
where bookings.boarding_passes.boarding_no  is null
