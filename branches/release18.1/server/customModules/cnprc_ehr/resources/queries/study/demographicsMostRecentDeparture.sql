SELECT depart1.Id,
       depart1.date AS MostRecentDeparture,
       depart1.destination.meaning AS MostRecentDepartureDestination
FROM (SELECT depart2.Id,
             MAX(depart2.date) AS MostRecentDeparture
      FROM study.departure depart2
      WHERE depart2.qcstate.publicdata = true
      GROUP BY depart2.Id) max_departures,
     study.departure depart1
WHERE depart1.lsid =
      (SELECT depart3.lsid
       FROM study.departure depart3
       WHERE depart3.date = max_departures.MostRecentDeparture
         AND depart3.Id = max_departures.Id)
