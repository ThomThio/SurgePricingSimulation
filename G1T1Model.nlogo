extensions [csv]
;;show csv:from-file ""


breed [commuters commuter]
breed [pTaxis pTaxi]
breed [nTaxis nTaxi]
breed [multiLoc multiLocs]
breed [locations location]



globals[

  hourHand
  dayCounter

  commuterPopulationOffset
  day
  days

  mins


  areaDemandFile
  distanceMapFile

  locationIds

  nTaxiRevenues
  pTaxiRevenues



  lastPopByArea

  nTaxiSurges

  pTaxiSurges


  nTaxiBaseRate
  pTaxiBaseRate

  testCurrentRevenue




]





commuters-own[
 origin; origin
 dest ;destination
 urgency; urgency
 priceSens ;price sensitivity

 pref


]

pTaxis-own[
  baseStrat

  multiplier
  withPsger?

  state
  taxiDest
  currentLoc

  englishDest


 distTravelled

  estFare

  locationSegment



]



nTaxis-own[

  baseStrat

  multiplier
  state
  withPsger?
  taxiDest
  currentLoc

  englishDest

  distTravelled
  estFare

  locationSegment

  testAgent?
  suppStrat

]

locations-own[
 isMultiplied?
 multiplier
 name
]

to openFiles
  let areaDemand_FP "Data/Area Demand Ratio.csv"
  ;let dest_FP "Project/Ratio of Destinations.csv"

  let distanceMapping "Data/Time taken.csv"

 set areaDemandFile csv:from-file areaDemand_FP
 set distanceMapFile csv:from-file distanceMapping
 ;set ratioDestFile csv:from-file dest_FP

  ;set areaDemandFile word areaDemandFile ";"  ; add semicolon for loop termination

end


to-report findAreaProp [dayParam hourParam areaId file];show;show

if hourParam >= 24[
 set hourParam 0
]


  ;0: day
  ;1: hour
  ;5: id
  ;return 3: %

  ;for loop

  let found? false
  let i 1 ;to start from one row after header, and so on


  while [found? = false]
  [
let tempDay 0
let tempHour 0
let fileid 0

     set tempDay item 0 item i file
    set tempHour item 1 item i file
    set fileid item 5 item i file


    if tempDay = dayParam and tempHour = hourParam and fileid = areaId[
     let prop item 3 item i file
     ;set found? true
     ; prop
     ; "Dist found"
      report prop
    ]
    set i (i + 1)


  ]

  report ""


end


to-report getDistributionFor [dayParam hourParam agentType];show;show;show
  let distribution []

  ifelse agentType = "nTaxi"[

  ][
   ifelse agentType = "pTaxi"[
   ][
     if agentType = "commuters"[

       ;let i 0
       ;while [i <= 10][
        ;  sentence "location" i
       ;]

       foreach locationIds [
         [i] ->

       let prop findAreaProp (dayParam) hourParam i areaDemandFile
      ;  prop
       set distribution lput prop distribution
       set i (i + 1)
       ]
     ]
   ]
  ]
  ; distribution
  report distribution

end

;create location nodes
 ;central - 0
  ;central east - 1
  ;north - 2
  ;south - 3
  ;east - 4
  ;west - 5
  ;southwest 6
  ;southeast 7
  ;northeast - 8
  ;northwest - 9
to generateLocations



  ;central
  create-locations 1
  ask location 0 [
   setxy 0 0
   set size 8
   set name "Central"
   set label "Central"
  ]


  ;central east
  create-locations 1
  ask location 1 [
   setxy 15 -2
   set size 10
   set name "Central East"
   set label "Central East"
  ]



   ;north
  create-locations 1
  ask location 2 [
   setxy 0 17
   set size 5
   set name "North"
   set label "North"
  ]


  ;south
  create-locations 1
  ask location 3 [
   setxy 0 -19
   set size 5
   set name "South"
   set label "South"
  ]


  ;east
  create-locations 1
  ask location 4 [
   setxy 35 0
   set size 5
   set name "East"
   set label "East"
  ]


  ;west
  create-locations 1
  ask location 5 [
   setxy -35 0
   set size 5
   set name "West"
   set label "West"
  ]


   ;southwest
  create-locations 1
  ask location 6 [
   setxy -18 -10
   set size 5
   set name "SouthWest"
   set label "SouthWest"
  ]


   ;southeast
  create-locations 1
  ask location 7 [
   setxy 22 -14
   set size 10
   set name "SouthEast"
   set label "SouthEast"
  ]


    ;northeast
  create-locations 1
  ask location 8 [
   setxy 21 8
   set size 5
   set name "NorthEast"
   set label "NorthEast"
  ]

   ;northwest
  create-locations 1
  ask location 9 [
   setxy -18 12
   set size 5
   set name "NorthWest"
   set label "NorthWest"
  ]

  ;CBD
  create-locations 1
  ask location 10 [
   setxy 0 -9
   set size 10
   set name "CBD"
   set label "CBD"
  ]

end

to distributeCommuters

  ;IF at timeframe t, distribute
  ;get difference in distribution, if commuters > 1, kill, else populate

  ;distribution according to data set
  ask commuters[
   let loc random-weighted locationIds [0.09 0.09 0.09 0.09 0.09 0.09 0.09 0.09 0.09 0.09 0.09]
   move-to location loc
   set origin loc
   set dest random-weighted locationIds [0.09 0.09 0.09 0.09 0.09 0.09 0.09 0.09 0.09 0.09 0.09]

   set xcor (xcor + random-float (1 - -1) - 1)
   set ycor (ycor + random-float (1 - -1) - 1)


  ]
end



;distribution of urgency, price sensitivity
to distributeCommuterAttributes

  ask commuters[


   set urgency (100 / 100 + random-float 1.0)
   ;set priceSens (priceSenseMin / 100 + random-float 1.0)
  ; ;show sentence "urgency distributed" urgency
  ]

end


to-report findSegment [loc]
  ifelse loc = 0[
    report [1 2 3 0 4 5 6]
  ][
  ifelse loc = 1[
    report [0 2 4 1]
  ][
    ifelse loc = 2[
    report [0 1 8 2]
  ][

    ifelse loc = 3[
    report [6 7 10 3 0]
  ][

    ifelse loc = 4[
    report [7 8 4 0]
  ][
    ifelse loc = 5[
    report [5 6 5 0]
  ][
    ifelse loc = 6[
    report [5 10 3 6 0]
  ][

    ifelse loc = 7[
    report [3 4 10 7 0]
  ][
    ifelse loc = 8[
    report [2 4 8 0]
  ][

    ifelse loc = 9[
    report [5 2 9 0]
  ][
    ifelse loc = 10[
    report [0 1 3 10]
  ][

  ]

  ]
  ]

  ]
  ]

  ]
  ]
  ]

  ]
  ]
  ]

end


to distributeTaxis

  ask-concurrent pTaxis[
   let loc random-weighted locationIds [0.09 0.09 0.09 0.09 0.09 0.09 0.09 0.09 0.09 0.09 0.09] ;for initialization purposes only
   move-to location loc
   set xcor (xcor + random-float (2 - -2) - 2)
   set ycor (ycor + random-float (2 - -2) - 2)
   set withPsger? false
   set currentLoc location loc

   let rand round (pTaxi_randomWeight / 100)
   let grouped round (100 - pTaxi_randomWeight) / 100

   set baseStrat random-weighted ["random" "areaSegment"] (list rand grouped)
   set locationSegment findSegment loc

  ]

  ask-concurrent nTaxis[
   let loc random-weighted locationIds [0.09 0.09 0.09 0.09 0.09 0.09 0.09 0.09 0.09 0.09 0.09] ;for initialization purposes only
   move-to location loc
   set xcor (xcor + random-float (2 - -2) - 2)
   set ycor (ycor + random-float (2 - -2) - 2)
   set withPsger? false
   set currentLoc location loc

   let rand (nTaxi_randomWeight / 100)
   let grouped (100 - nTaxi_randomWeight) / 100

   set baseStrat random-weighted ["random" "areaSegment"] (list rand grouped)
;set baseStrat "centralBias"
   set locationSegment findSegment loc

  ]



end


to generateAgentLook
  ask-concurrent commuters[
   set shape "person"

   ifelse pref = "none"[
    set color white
   ][
   set color yellow
   ]

   set size 1
  ]

  ask-concurrent pTaxis [
    set shape "car"
    set size 1.5
    set color blue



  ]


  ask-concurrent nTaxis [
    set shape "car"
    set size 1.5
    set color green

    if testAgent? = true [
     set color orange
  ;set label "TEST AGENT"
  set size 5
    ]
  ]

  ask-concurrent locations[
   set shape "circle"
   set color grey
   set size 1

  ]

end



;for other taxis, supercedes
to-report findSurge [popByArea supplyByArea]
  let compareList []
  let surgeList []
  ;show popByArea
  ;show supplyByArea
 (foreach popByArea supplyByArea[
   [p s] ->

     ifelse s = 0 [
       set compareList lput 1 compareList
     ][
    let ratio p / s
    set compareList lput ratio compareList
     ]


 ])

 ;show compareList
 let locCount 0
 foreach compareList[
   [c] ->
 let nest []
    ifelse c >= 20[
      set nest lput 2.4 nest
      set nest lput locCount nest
      set surgeList lput nest surgeList
    ][
      ifelse c >= 10[
      set nest lput 2.2 nest
      set nest lput locCount nest
      set surgeList lput nest surgeList
    ][
      ifelse c >= 5[
      set nest lput 1.8 nest
      set nest lput locCount nest
      set surgeList lput nest surgeList
    ][
      ifelse c >= 3[
      set nest lput 1.5 nest
      set nest lput locCount nest
      set surgeList lput nest surgeList
    ][
      ifelse c >= 1[
      set nest lput 1.3 nest
      set nest lput locCount nest
      set surgeList lput nest surgeList
    ]
      [
     set nest lput 1 nest
      set nest lput locCount nest
      set surgeList lput nest surgeList
    ]

    ]]
    ]
    ]
    set nest []
    set locCount (locCount + 1)
 ]



  report surgeList

end


to-report distributeTaxiStrat

  ;choose a random location if no psg

  ;always go to cbd


  ;only go to areas within radius of 5 (if doing jobs in the east, likely to stay in the east)





end


to-report findFare [o d taxiType surgeOn? base surgeAmt]

  let found? false
  let i 1 ;to start from one row after header, and so on

if o = d[
 ;;show "Origin is same as destination!"
]

  while [found? = false]
  [


     let ori item 1 item i distanceMapFile
    let desti item 3 item i distanceMapFile






    if ori = o and desti = d[

      let timeTaken item 4 item i distanceMapFile
    let distanceNeeded item 5 item i distanceMapFile
      let fare 0 ;not counting surge yet, as this is calculated outside

      ifelse taxiType = "nTaxi"[

        ifelse surgeOn? = false [
        set fare timeTaken * nTaxi_chargePerMinute + nTaxi_chargePerKM * distanceNeeded + base
        ][
          set fare timeTaken * nTaxi_chargePerMinute + nTaxi_chargePerKM * distanceNeeded + base
        ]



      ][

        if taxiType = "pTaxi"[

        set fare timeTaken * 0.16 + distanceNeeded  * 0.50 + base
        ]



      ]

      if surgeAmt != ""[
          set fare (fare * surgeAmt)
        ]
      ;;show sentence "Fare for " taxiType
      ;;show fare



     ;set found? true
     ;;show prop
     ;;show "Dist found"
      report fare
    ]
    set i (i + 1)
  ]

  report ""

end


to-report adjPrice [current sens]

  report current + ((1 - sens) * historicMaxPrice)

end

to chooseTaxis
  let searchRad 5

  ask-concurrent commuters[
    let org origin
   ; ;show sentence "Commuter at " [name] of location org
    ;carefully[
    let nTaxiPrice ""
    ifelse nTaxisSurgeOn? [
      set nTaxiPrice findFare origin dest "nTaxi" true nTaxiBaseRate item 0 item origin nTaxiSurges
    ][
     set nTaxiPrice findFare origin dest "nTaxi" false nTaxiBaseRate ""
    ]



   let pTaxiPrice findFare origin dest "pTaxi" true pTaxiBaseRate item 0 item origin pTaxiSurges

    let adj_nTaxiPrice adjPrice nTaxiPrice globalPriceSens

    let adj_pTaxiPrice adjPrice pTaxiPrice globalPriceSens


    ;if commuter urgent, price does not meet criteria, take anyway

      let nTaxiAvail any? nTaxis in-radius (searchRad + urgency) with [withPsger? = false]
      let pTaxiAvail any? pTaxis in-radius (searchRad + urgency) with [withPsger? = false]

      let coef (1 - globalPriceSens) * historicMaxPrice

      ;let pTaxiPriceCheck (pTaxiPrice - adj_pTaxiPrice) <= coef


      ;show nTaxiPrice / adj_nTaxiPrice
      ;show pTaxiPrice / adj_pTaxiPrice

      ifelse (adj_nTaxiPrice - adj_pTaxiPrice) <= coef and (adj_nTaxiPrice - adj_pTaxiPrice) >= 0[

         set pref "None"
         ;show "BOTH"

         let decision random-weighted ["N" "P"][0.5 0.5]
         ifelse decision = "N" [
         carefully[
           ask one-of nTaxis in-radius searchRad with [withPsger? = false][
       ;set label "Psg picked up"
      set state "PSG"
      set taxiDest location org
      set englishDest [name] of taxiDest
      set withPsger? true

      set estFare nTaxiPrice
    ; show "Chose ntaxi by random"

      ]
           die

         ][

       ;  ;show "no ntaxis available"
         ]
        ]
         [
           carefully[
          ask one-of pTaxis in-radius searchRad with [withPsger? = false][
       set label "Psg picked"
      set state "PSG"
      set taxiDest location org
      set englishDest [name] of taxiDest
      set withPsger? true

      set estFare pTaxiPrice
     ; show "Chose ptaxi by random"

      ]

         die

         ][
       ; show "no pTaxis to board"
         ]
         ]

      ][

       ifelse (adj_nTaxiPrice - adj_pTaxiPrice) < 0[
         carefully[
           ask one-of nTaxis in-radius searchRad with [withPsger? = false][
       set label "Psg picked"
      set state "PSG"
      set taxiDest location org
      set englishDest [name] of taxiDest
      set withPsger? true

      set estFare nTaxiPrice
    ; show "Chose ntaxi as better price"

      ]
      die
            ][
            ;show "no ntaxis found"
            ]
       ][
         carefully[
           ask one-of pTaxis in-radius searchRad with [withPsger? = false][
       set label "Psg picked"
      set state "PSG"
      set taxiDest location org
      set englishDest [name] of taxiDest
      set withPsger? true

      set estFare pTaxiPrice
    ; show "Chose ptaxi as better price"

      ]
      die
            ][
            ;show "no ntaxis found"
            ]
       ]

      ]





]


end


to moveTaxis [popByArea];show;show;show

  ask-concurrent nTaxis[

    ;update location
    set currentLoc one-of locations in-radius 3




    ;if having passenger, move to the destination of the passenger. If at the current location of taxi is at destination, reset psg status and destination
    ifelse withPsger?[

      ifelse currentLoc != taxiDest[
        ; "With Psg"
        set label sentence "W Psg, Move to " englishDest
        set state "PSG"
        ;continue moving towards destination
        face taxiDest
        ;ifelse peakHour, fwd 0.5[

ifelse testAgent? = true[
  ifelse testAgentSpeed = "normal" [

    ifelse badWeather = true[
     fd 1
    ][
  fd 2
    ]


  ][
  ifelse testAgentSpeed = "slow" [
  ifelse badWeather = true[
     fd 0.5
    ][
  fd 1
    ]
  ][

   ifelse testAgentSpeed = "2x" [
  ifelse badWeather = true[
     fd 2
    ][
  fd 4
    ]
  ][
    ifelse testAgentSpeed = "fastWOPsg" and withPsger? = true[
              fd 2

  ][
    ifelse testAgentSpeed = "fastWOPsg" and withPsger? = false[
      fd 4
  ][

  ]

  ]
  ]
  ]
  ]

][
  ifelse badWeather = true[
     fd 1
    ][
  fd 2
    ]
]

        set distTravelled (distTravelled + 2)


      ][
        set label "Psg dropped"
        set state "DROPPED"
       ;set taxiDest ""
       set withPsger? false

       set distTravelled 0
       set nTaxirevenues (nTaxiRevenues + estFare)

       if testAgent? = true[
        set testCurrentRevenue (testCurrentRevenue + estFare)
       ]

       set estFare ""
       set multiplier ""



      ]



    ][
      ;if no passenger, move to one of the locationIds
     ; set label sentence "No Psg :( Moving to " englishDest
      ;set withPsger? false


      ;so that next destination is chosen only once. can add surge pricing logic here
      ifelse state != "LOOKING"[

        let chosen 0
        ifelse nTaxisSurgeOn? = true[

         let chosenList []
         ;let surgeList nTaxiSurges
         ;if testAgent? = true [
          ; set surgeList pTaxiSurges
         ;]

        foreach nTaxiSurges [
          [tuple] ->

          let n item 0 tuple
       ;if the distance is not worth it, go to default strat
      if n >= 1.1[
       set chosenList lput tuple chosenList
      ]

        ]
          set chosen item 1 one-of chosenList

        ifelse empty? chosenList [
           ifelse testAgent? = false and baseStrat = "random"[
            set taxiDest one-of locations
          ][
            ifelse testAgent? = false and baseStrat = "areaSegment"[
            set taxiDest location one-of locationSegment
          ][

            ifelse testAgent? = true and baseStrat = "random"[
            set taxiDest one-of locations
          ][
            ifelse testAgent? = true and baseStrat = "areaSegment"[
            set taxiDest location one-of locationSegment
          ][
            ifelse testAgent? = true and baseStrat = "centralBias"[
              set taxiDest location 0

            ][
              ifelse testAgent? = true and baseStrat = "spyUber"[
              ;set taxiDest location position max pTaxiSurges pTaxiSurges

              foreach pTaxiSurges [
          [tuple] ->

          let n item 0 tuple
       ;if the distance is not worth it, go to default strat
      if n >= 1.1[
       set chosenList lput tuple chosenList
      ]

        ]
          set chosen item 1 one-of chosenList
              set taxiDest location chosen
            ][

              set taxiDest location 0
            ]
            ]
          ]
          ]


          ]
        ]
        ]
        [

        set chosen item 1 one-of chosenList

        ]





        set taxiDest location chosen





        ][
          set label ""
         ;IMPLEMENT BASE STRAT HERE

         ifelse testAgent? = false and baseStrat = "random"[
            set taxiDest one-of locations
          ][
            ifelse testAgent? = false and baseStrat = "areaSegment"[
            set taxiDest location one-of locationSegment
          ][

            ifelse testAgent? = true and baseStrat = "random"[
            set taxiDest one-of locations
          ][
            ifelse testAgent? = true and baseStrat = "areaSegment"[
            set taxiDest location one-of locationSegment
          ][
            ifelse testAgent? = true and baseStrat = "centralBias"[
              set taxiDest location 0



            ][
              ifelse testAgent? = true and baseStrat = "spyUber"[
              ;set taxiDest location position max pTaxiSurges pTaxiSurges
                let chosenList []
              foreach pTaxiSurges [
          [tuple] ->

          let n item 0 tuple
       ;if the distance is not worth it, go to default strat
      if n >= 1.1[
       set chosenList lput tuple chosenList
      ]

        ]
          set chosen item 1 one-of chosenList
              set taxiDest location chosen
            ][
              set taxiDest location 0
            ]
            ]
          ]
          ]


          ]
        ]


        ]





      ][

        if currentLoc = taxiDest [

        let chosen 0


         let chosenList []
        foreach nTaxiSurges[
          [tuple] ->

          let n item 0 tuple
       ;if the distance is not worth it, go to default strat
      if n >= 1.1[
       set chosenList lput tuple chosenList
      ]

        ]

        ifelse empty? chosenList [
           ifelse baseStrat = "random"[
            set taxiDest one-of locations
            set chosen [who] of taxiDest
          ][
            ifelse baseStrat = "areaSegment"[
            set taxiDest location one-of locationSegment
            set chosen [who] of taxiDest
          ][



          ]

          ]
        ][


        set chosen item 1 one-of chosenList

        ]


        set taxiDest location chosen

        ]


      ]

      set englishDest [name] of taxiDest
      face taxiDest
      ifelse badWeather = true[
     fd 1
    ][
  fd 2
    ]

      set state "LOOKING"
    ]


    ]








 ask-concurrent pTaxis[

    ;update location
    set currentLoc one-of locations in-radius 2


    ;if having passenger, move to the destination of the passenger. If at the current location of taxi is at destination, reset psg status and destination
    ifelse withPsger?[

      ifelse currentLoc != taxiDest[
        ; "With Psg"
        set label sentence "W Psg, Move to" englishDest
        set state "PSG"
        ;continue moving towards destination
        face taxiDest
        ;ifelse peakHour, fwd 0.5[


        ifelse badWeather = true[
     fd 1
    ][
  fd 2
    ]
        set distTravelled (distTravelled + 2)


      ][


        set label "Psg dropped"
        set state "DROPPED"
       ;set taxiDest ""
       set withPsger? false

       set distTravelled 0
       set pTaxirevenues (pTaxiRevenues + estFare)
       set estFare ""
       set multiplier ""

      ]



    ][
      ;if no passenger, move to one of the locationIds
      ;set label sentence "No Psg :( Moving to " englishDest
      ;set withPsger? false


      ;so that next destination is chosen only once. can add surge pricing logic here
      ifelse state != "LOOKING"[

        let chosen 0


         let chosenList []
        foreach pTaxiSurges[
          [tuple] ->

          let n item 0 tuple
       ;if the distance is not worth it, go to default strat
      if n >= 1.1[
       set chosenList lput tuple chosenList
      ]

        ]

        ifelse empty? chosenList [
           ifelse baseStrat = "random"[
            set taxiDest one-of locations
            set chosen [who] of taxiDest
          ][
            ifelse baseStrat = "areaSegment"[
            set taxiDest location one-of locationSegment
            set chosen [who] of taxiDest
          ][



          ]

          ]
        ][


        set chosen item 1 one-of chosenList

        ]


        set taxiDest location chosen


      ][
        set label ""
        ;still looking, but no psnger if I am at the destination i want to be

        if currentLoc = taxiDest[

        let chosen 0


         let chosenList []
        foreach pTaxiSurges[
          [tuple] ->

          let n item 0 tuple
       ;if the distance is not worth it, go to default strat
      if n >= 1.1[
       set chosenList lput tuple chosenList
      ]

        ]

        ifelse empty? chosenList [
           ifelse baseStrat = "random"[
            set taxiDest one-of locations
            set chosen [who] of taxiDest
          ][
            ifelse baseStrat = "areaSegment"[
            set taxiDest location one-of locationSegment
            set chosen [who] of taxiDest
          ][



          ]

          ]
        ][


        set chosen item 1 one-of chosenList

        ]


        set taxiDest location chosen



        ]


      ]


      ]

     ; taxiDest






      set englishDest [name] of taxiDest
      face taxiDest
      ifelse badWeather = true[
     fd 1
    ][
  fd 2
    ]

      set state "LOOKING"
    ]











end









to setup

  clear-all
  reset-ticks
  import-drawing "sg.png"
  resize-world -40 40 -25 25
  openFiles

  set days ["Monday" "Tuesday" "Wednesday" "Thursday" "Friday"]
  set locationIds [0 1 2 3 4 5 6 7 8 9 10]
  ;set start day as 1, hour at 8am
  set dayCounter 1
  set hourHand 0





  generateLocations

  create-commuters numCommuters
  distributeCommuters


 create-nTaxis numNTaxis
 create-pTaxis numPTaxis

  distributeTaxis
  distributeCommuterAttributes

  generateAgentLook
  ask one-of nTaxis [
    set testAgent? true
    set baseStrat testAgentStrat
    set suppStrat testAgentSupp
    ifelse suppStrat = "spawnCentralOnly" [
      move-to location 0


    ][
    ifelse suppStrat = "spawnSEOnly" [
    move-to location 7
    ][


    ]




  ]
  ]



end


;to balance demand per day/hour at each area
to-report balancePopByArea [newDist agentType]

  ;find current balance per location
  let pastPopByArea []
  let newPopByArea []



  if agentType = "commuters"[


    foreach newDist[
      [d] ->
      let popArea (d * numCommuters)
      set newPopByArea lput round popArea newPopByArea

    ]



    ;find balance to be


    ask locations[
      let id who
      let commCount count commuters with [origin = id];
       ;show sentence "Commcount" commCount
      ;let commCount count commuters with [origin = name]
      set pastPopByArea lput round commCount pastPopByArea
    ]
  ]

  ; show sentence "past pop" pastPopByArea
   ;show sentence "req pop" newPopByArea

  let topUp []
  (foreach pastPopByArea newPopByArea [
       [x1 x2] -> let diff x2 - x1
        set topUp lput diff topUp

     ])
  ; topUp


  ;difference. If +ve, add more ppl. If -ve, kill
     ;after adding ppl, move them to location.
  show sentence "Bal" topUp
   show locationIds

  let locCounter 0


while [locCounter <= 10][
  let locName [name] of location locCounter
  ; sentence "Location" locName

let killOrPop item locCounter topUp

ifelse (killOrPop <= 0)[
  set killOrPop abs killOrPop
 ;  sentence "Kill" killOrPop

  ;ask location locCounter [ask-concurrent n-of killOrPop commuters in-radius 3 [die]]
carefully [
ask n-of killOrPop commuters with [origin = locCounter][die]
][
  ask commuters with [origin = locCounter][die]
]


][
 ;  sentence "Creating" killOrPop

  create-commuters killOrPop [
    move-to location locCounter
   set xcor (xcor + random-float (1 - -1) - 1)
   set ycor (ycor + random-float (1 - -1) - 1)
   set origin locCounter
   set dest random-weighted locationIds [0.09 0.09 0.09 0.09 0.09 0.09 0.09 0.09 0.09 0.09 0.09]
  ]

]

set locCounter (locCounter + 1)
]

report newPopByArea


end


to-report findSupplyByArea [taxiType]
  let supplyByArea []
 foreach locationIds[
   [loc] ->

let num ""
  ifelse taxiType = "nTaxi"[
    set num count nTaxis with [withPsger? = false and currentLoc = location loc]

  ][
    set num count pTaxis with [withPsger? = false and currentLoc = location loc]

  ]
  set supplyByArea lput num supplyByArea

 ]
 report supplyByArea

end

to-report findDemandByArea;show
  let currentDemand []
  ask locations[
      let id who
      let commCount count commuters with [origin = id]
      ; sentence "Commcount" commCount
      ;let commCount count commuters with [origin = name]
      set currentDemand lput round commCount currentDemand
    ]
  report currentDemand
end

to timecheck
   ;ask-concurrent commuters[
   ; set origin [who] of one-of locations in-radius 3
  ;]



  let popByArea []

if dayCounter > 5[
    set dayCounter 1
    set hourHand 0
  ]

    if hourHand > 23[
     set hourHand 0
   ]

      set day item (dayCounter - 1) days


;show dayCounter



  ;timer tick calculation
  ;1 ticks = 5 min
  ;12 ticks = 1 hour
  ;288 ticks = 1 day

  ;INCREMENT day after 268
  ;CHANGE distribution according to day
  ;STOP @ 14448 ticks


  if ticks mod 12 = 0[
   show "ONE HOUR HAS PASSED"
   set hourHand (hourHand + 1)

   let commuterDistribution getDistributionFor (dayCounter) hourHand "commuters"
   ;;show "This runs!"
   set popByArea balancePopByArea commuterDistribution "commuters"









  ]

  if (ticks) mod 287 = 0 and ticks > 286[
    show "ONE DAY HAS PASSED"
    set dayCounter (dayCounter + 1)

  ]










  ifelse popByArea = [][
    set popByArea findDemandByArea
  ][
    set lastPopByArea popByArea
  ]

 ; if ticks > 12[
  ;  let commuterDistribution getDistributionFor dayCounter hourHand "commuters"

   ;balancePopByArea commuterDistribution "commuters"
   ;let nTaxiDistribution getDistributionFor dayCounter hourHand "nTaxis"
   ;let pTaxiDistribution getDistributionFor dayCounter hourHand "pTaxis"
  ;]



  let nTaxiSupplyByArea findSupplyByArea "nTaxi"
let pTaxiSupplyByArea findSupplyByArea "pTaxi"

;show sentence "new pop by area" popByArea
   ;show sentence "nTaxis" nTaxiSupplyByArea
   ;show sentence "pTaxis" pTaxiSupplyByArea

set nTaxiSurges findSurge popByArea nTaxiSupplyByArea
set pTaxiSurges findSurge popByArea pTaxiSupplyByArea




moveTaxis popByArea



end


to go
;carefully[
  ;get commuters to update wherevery they are close to a location

if nTaxisSurgeOn? = true[
   set nTaxiBase 2.5
   set nTaxi_chargePerMinute 0.16
   set nTaxi_chargePerKm 0.5
  ]

if nTaxisproposedPrice? = true[
  set  nTaxiBase 3.0
   set nTaxi_chargePerMinute 0.25
   set nTaxi_chargePerKm 0.52
]

if setToNormal? = true[
  set  nTaxiBase 3.6
   set nTaxi_chargePerMinute 0.29
   set nTaxi_chargePerKm 0.55
]

  timecheck
  distributeCommuterAttributes ;needs to be done as rebalancing is done every hour
  generateAgentLook
  chooseTaxis

;][
;]

  tick


end



to-report random-weighted [values weights]
     let selector (random-float sum weights)
     let running-sum 0
     (foreach values weights [
       [x1 x2] -> set running-sum (running-sum + x2)
         if (running-sum > selector) [
             report x1
         ]
     ])
end
@#$#@#$#@
GRAPHICS-WINDOW
303
-44
1273
570
-1
-1
11.88
1
10
1
1
1
0
0
0
1
-40
40
-25
25
0
0
1
ticks
30.0

BUTTON
39
32
105
65
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
125
33
188
66
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
12
179
104
224
day
day
17
1
11

MONITOR
110
179
222
224
Hour Of The Day
hourHand
17
1
11

SLIDER
15
282
174
315
numCommuters
numCommuters
0
500
500.0
1
1
NIL
HORIZONTAL

BUTTON
71
76
152
109
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1289
15
1464
48
numNTaxis
numNTaxis
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
1289
62
1462
95
numPTaxis
numPTaxis
0
100
40.0
1
1
NIL
HORIZONTAL

MONITOR
702
192
830
237
Demand @ Central
count commuters with [origin = 0]
17
1
11

MONITOR
945
226
1043
271
Demand @ CE
count commuters with [origin = 1]
17
1
11

MONITOR
808
15
924
60
Demand @ North
count commuters with [origin = 2]
17
1
11

MONITOR
765
524
883
569
Demand @ South
count commuters with [origin = 3]
17
1
11

MONITOR
1158
196
1276
241
Demand @ East
count commuters with [origin = 4]
17
1
11

MONITOR
309
188
419
233
Demand @ West
count commuters with [origin = 5]
17
1
11

MONITOR
503
410
602
455
Demand @ SW
count commuters with [origin = 6]
17
1
11

MONITOR
1069
458
1165
503
Demand @ SE
count commuters with [origin = 7]
17
1
11

MONITOR
493
56
595
101
Demand @ NW
count commuters with [origin = 9]
17
1
11

MONITOR
810
402
918
447
Demand @ CBD
count commuters with [origin = 10]
17
1
11

MONITOR
12
130
131
175
Total commuters
count commuters
17
1
11

SWITCH
434
614
612
647
nTaxisSurgeOn?
nTaxisSurgeOn?
1
1
-1000

SLIDER
1289
140
1462
173
nTaxiBase
nTaxiBase
0
3.60
3.6
0.01
1
NIL
HORIZONTAL

SLIDER
1550
139
1723
172
pTaxiBase
pTaxiBase
0
3
2.5
0.01
1
NIL
HORIZONTAL

MONITOR
1284
299
1823
344
nTaxiSurge by Area
nTaxiSurges
17
1
11

MONITOR
1285
362
1822
407
pTaxiSurge by Area
pTaxiSurges
17
1
11

SLIDER
1549
15
1735
48
nTaxi_randomWeight
nTaxi_randomWeight
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
1550
55
1736
88
pTaxi_randomWeight
pTaxi_randomWeight
0
100
50.0
1
1
NIL
HORIZONTAL

PLOT
1560
414
1823
594
Average Revenue per Taxi Type
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"nTaxis" 1.0 0 -10899396 true "" "plot nTaxiRevenues / (numNTaxis + 0.00001)"
"pTaxis" 1.0 0 -14454117 true "" "plot pTaxiRevenues / (numPTaxis + 0.00001)"
"testAgent" 1.0 0 -955883 true "" "plot testCurrentRevenue"

SLIDER
15
435
175
468
historicMaxPrice
historicMaxPrice
0
12.9
12.9
0.1
1
NIL
HORIZONTAL

PLOT
1284
414
1552
594
Taxi Occupancy Rate
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"nTaxis" 1.0 0 -15040220 true "" "plot count nTaxis with [withPsger?] / (count nTaxis + 0.0001) * 100"
"pTaxis" 1.0 0 -14730904 true "" "plot count pTaxis with [withPsger?] / (count pTaxis + 0.0001) * 100"

SLIDER
13
363
175
396
globalPriceSens
globalPriceSens
0
1
0.9
0.1
1
NIL
HORIZONTAL

SLIDER
1290
180
1465
213
nTaxi_chargePerMinute
nTaxi_chargePerMinute
0
0.7
0.29
0.01
1
NIL
HORIZONTAL

SLIDER
1290
220
1463
253
nTaxi_chargePerKM
nTaxi_chargePerKM
0
0.6
0.55
0.01
1
NIL
HORIZONTAL

CHOOSER
430
818
542
863
testAgentStrat
testAgentStrat
"random" "areaSegment" "centralBias" "spyUber" "centralAndSEOnly"
3

CHOOSER
548
818
658
863
testAgentSupp
testAgentSupp
"spawnCentralOnly" "spawnSEOnly" "normalSpawn"
2

SWITCH
1066
615
1204
648
setToNormal?
setToNormal?
0
1
-1000

CHOOSER
666
818
771
863
testAgentSpeed
testAgentSpeed
"slow" "normal" "fastWOPsg" "2x"
3

MONITOR
996
95
1094
140
Demand @ NE
count commuters with [origin = 8]
17
1
11

SWITCH
429
935
553
968
badWeather
badWeather
1
1
-1000

TEXTBOX
185
282
310
341
total commuters spawned, \ndistributed across areas later
11
0.0
1

TEXTBOX
182
365
304
395
sensitivity to price diff  (nTaxi vs pTaxi)
11
0.0
1

TEXTBOX
182
438
276
468
full-info of how much max price difference can go
11
0.0
1

TEXTBOX
1550
190
1800
235
Default: pTaxi_chargePerMinute 0.16\n\nDefault: pTaxi_chargePerKM 0.5
11
0.0
1

TEXTBOX
34
599
393
1034
Try these!\n1. Switch on/off surge pricing for normal taxis. Could nTaxis compete without using surge pricing? (right)\n\n2. Play around with nTaxi base rates, charge per min, charge per km to see what makes them more performant without surge (top left) (turn off surge, reset prices, then propose new prices)\n\n\n\nOther things to try:\n1. If commuters had full-information of pricing history (historicMaxPrice, how would this affect their decision to take each type of taxi?) How far back should 'memory' go?\n\n2. For our testAgent (orange taxi), he is a nTaxi, following conventional rules of the nTaxis. Play around with different main strategies, sub-strategies to see if he can be an outstanding taxi driver. (right)\n\n3. How sensitive should commuters be such that is follows real-life phenomena? How can companies use this info? (hint: promos as offensive strat)\n\n4. How does weather affect performance?
11
0.0
1

TEXTBOX
1068
592
1318
622
Reset nTaxi rates
11
0.0
1

TEXTBOX
1756
18
1915
103
e.g. From scale of 0-100, proportion of taxis making random choices compared to those taking responsibility of area
11
0.0
1

SWITCH
435
669
614
702
nTaxisproposedPrice?
nTaxisproposedPrice?
1
1
-1000

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="BaseTest" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>dayCounter = 5 and hourHand &gt; 23</exitCondition>
    <metric>nTaxiRevenues / (numNTaxis + 0.00001)</metric>
    <metric>pTaxiRevenues / (numPTaxis + 0.00001)</metric>
    <enumeratedValueSet variable="numCommuters">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numNTaxis">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="historicMaxPrice">
      <value value="12.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pTaxiBase">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pTaxi_randomWeight">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxiBase">
      <value value="3.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxisproposedPrice?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxi_randomWeight">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="badWeather">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testAgentStrat">
      <value value="&quot;spyUber&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxisSurgeOn?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testAgentSupp">
      <value value="&quot;spawnCentralOnly&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxi_chargePerMinute">
      <value value="0.29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxi_chargePerKM">
      <value value="0.55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="globalPriceSens">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testAgentSpeed">
      <value value="&quot;2x&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setToNormal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numPTaxis">
      <value value="40"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="AgentTestSpying" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>dayCounter = 5 and hourHand &gt; 23</exitCondition>
    <metric>nTaxiRevenues / (numNTaxis + 0.00001)</metric>
    <metric>pTaxiRevenues / (numPTaxis + 0.00001)</metric>
    <metric>testCurrentRevenue</metric>
    <enumeratedValueSet variable="numCommuters">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numNTaxis">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="historicMaxPrice">
      <value value="12.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pTaxiBase">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pTaxi_randomWeight">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxiBase">
      <value value="3.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxisproposedPrice?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxi_randomWeight">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="badWeather">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testAgentStrat">
      <value value="&quot;spyUber&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxisSurgeOn?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testAgentSupp">
      <value value="&quot;normalSpawn&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxi_chargePerMinute">
      <value value="0.29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxi_chargePerKM">
      <value value="0.55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="globalPriceSens">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testAgentSpeed">
      <value value="&quot;normal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setToNormal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numPTaxis">
      <value value="40"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="AgentTestSpyingSpeeding" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>dayCounter = 5 and hourHand &gt; 23</exitCondition>
    <metric>nTaxiRevenues / (numNTaxis + 0.00001)</metric>
    <metric>pTaxiRevenues / (numPTaxis + 0.00001)</metric>
    <metric>testCurrentRevenue</metric>
    <enumeratedValueSet variable="numCommuters">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numNTaxis">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="historicMaxPrice">
      <value value="12.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pTaxiBase">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pTaxi_randomWeight">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxiBase">
      <value value="3.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxisproposedPrice?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxi_randomWeight">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="badWeather">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testAgentStrat">
      <value value="&quot;spyUber&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxisSurgeOn?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testAgentSupp">
      <value value="&quot;normalSpawn&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxi_chargePerMinute">
      <value value="0.29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxi_chargePerKM">
      <value value="0.55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="globalPriceSens">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testAgentSpeed">
      <value value="&quot;fastWOPsg&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setToNormal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numPTaxis">
      <value value="40"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="DynamicPricingTaxi" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>dayCounter = 5 and hourHand &gt; 23</exitCondition>
    <metric>nTaxiRevenues / (numNTaxis + 0.00001)</metric>
    <metric>pTaxiRevenues / (numPTaxis + 0.00001)</metric>
    <enumeratedValueSet variable="numCommuters">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numNTaxis">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="historicMaxPrice">
      <value value="12.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pTaxiBase">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pTaxi_randomWeight">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxiBase">
      <value value="3.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxisproposedPrice?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxi_randomWeight">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="badWeather">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testAgentStrat">
      <value value="&quot;spyUber&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxisSurgeOn?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testAgentSupp">
      <value value="&quot;spawnCentralOnly&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxi_chargePerMinute">
      <value value="0.29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxi_chargePerKM">
      <value value="0.55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="globalPriceSens">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testAgentSpeed">
      <value value="&quot;2x&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setToNormal?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numPTaxis">
      <value value="40"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="DynamicPricingTaxi" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>dayCounter = 5 and hourHand &gt; 23</exitCondition>
    <metric>nTaxiRevenues / (numNTaxis + 0.00001)</metric>
    <metric>pTaxiRevenues / (numPTaxis + 0.00001)</metric>
    <enumeratedValueSet variable="numCommuters">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numNTaxis">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="historicMaxPrice">
      <value value="12.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pTaxiBase">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pTaxi_randomWeight">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxiBase">
      <value value="3.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxisproposedPrice?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxi_randomWeight">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="badWeather">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testAgentStrat">
      <value value="&quot;spyUber&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxisSurgeOn?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testAgentSupp">
      <value value="&quot;spawnCentralOnly&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxi_chargePerMinute">
      <value value="0.29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxi_chargePerKM">
      <value value="0.55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="globalPriceSens">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testAgentSpeed">
      <value value="&quot;2x&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setToNormal?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numPTaxis">
      <value value="40"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="PriceWarTaxi" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>dayCounter = 5 and hourHand &gt; 23</exitCondition>
    <metric>nTaxiRevenues / (numNTaxis + 0.00001)</metric>
    <metric>pTaxiRevenues / (numPTaxis + 0.00001)</metric>
    <enumeratedValueSet variable="numCommuters">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numNTaxis">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="historicMaxPrice">
      <value value="12.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pTaxiBase">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pTaxi_randomWeight">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxiBase">
      <value value="3.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxisproposedPrice?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxi_randomWeight">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="badWeather">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testAgentStrat">
      <value value="&quot;spyUber&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxisSurgeOn?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testAgentSupp">
      <value value="&quot;spawnCentralOnly&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxi_chargePerMinute">
      <value value="0.29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nTaxi_chargePerKM">
      <value value="0.55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="globalPriceSens">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testAgentSpeed">
      <value value="&quot;2x&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setToNormal?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numPTaxis">
      <value value="40"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
