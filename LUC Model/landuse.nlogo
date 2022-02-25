extensions [ gis r ]         ; GIS extension provides ability to load both vector and raster data into the model
                             ; R extension provides primitives to use the R software for statistical analysis

globals [
  land-use-map               ; represents the land use map for Northern Ireland
  antrim                     ; defines the boundary lines for county antrim
  down                       ; defines the boundary lines for county down
  tyrone                     ; defines the boundary lines for county tyrone
  londonderry                ; defines the boundary lines for county londonderry
  armagh                     ; defines the boundary lines for county armagh
  fermanagh                  ; defined the boundary lines for county fermanagh

  number-farms-total         ; used to define the total number of farmer agents present in the simulation
  farms-traditional          ; number of agents part of the traditional farming group
  farms-commercial           ; number of agents part of the commercial farming group
  farms-supplementary        ; number of agents part of the supplementary farming group

  number-farms-county        ; reports the number of farms in the county selected by the user
  county-selected            ; reports the name of the county selected by the user

  policy1-number             ; counter for the number of farmers that participated in the agroforestry policy
  policy2-number             ; counter for the number of farmers that participated in the bioenergy policy

  ;; Ecological attributes
  trees-planted-hectares     ; total number of hectares converted to agroforestry
  crops-planted-hectares     ; total number of hectares converted to bioenergy crops
  GHG-emissions-initial      ; current level of greenhouse gases emitted by the agricultural sector
  agro-sequest-ha-mt         ; sequestration rate of agroforestry per hectare per year
  bio-sequest-ha-mt          ; sequestration rate of bioenergy crops per hectare per year
  GHG-reductions             ; reductions in greenhouse gas emissions from initial level to current level

  supp-ha                    ; reports the total hectares of land belonging to the supplementary farming group
  comm-ha                    ; reports the total hectares of land belonging to the commercial farming group
  trad-ha                    ; reports the total hectares of land belonging to the traditional farming group

  ; variables used to show or hide the different agent groups
  view-traditional-farms?
  view-commercial-farms?
  view-supplementary-farms?

  ; variables used to show or hide the different network links
  view-traditional-links?
  view-commercial-links?
  view-supplementary-links?

  ; variables used to store the hectares of agroforestry and bioenergy crops planted at each time step
  agro-list
  bio-list

  ; variables used to store the number of hectares and total cost of policies
  total-cost
  total-hectares
]

; the three types of farmer groups that each represent different decision making processes
breed [ traditionalists traditionalist ]
breed [ commercials commercial ]
breed [ supplementaries supplementary]

patches-own [
  land-use                   ; different types of land use classification represented numerically
  land-cover                 ; different types of land cover classification (forest, agriculture, etc.)

  belong-to                  ; used to indentify which farmer group the patch belongs to
  field-owner-id             ; identifies the owner of a field

  inAntrim?                  ; used to determine if a patch is located in county antrim
  inDown?                    ; used to determine if a patch is located in county down
  inTyrone?                  ; used to determine if a patch is located in county tyrone
  inLondonderry?             ; used to determine if a patch is located in county londonderry
  inArmagh?                  ; used to determine if a patch is located in county armagh
  inFermanagh?               ; used to determine if a patch is located in county fermanagh
]

turtles-own [

  ;; Social attributes

  farmer-id                  ; farmer agent id
  farmer-age                 ; age of the decision maker on the farm
  farm-size                  ; size of the farm in patches
  farm-size-hectares         ; size of the farm in hectares (where 1 patch is equal to 50 hectares)
  farm-successor             ; if the current farm head has a successor to inherit the farm (True/False)
  farm-retirement            ; if the farm head plans on retiring (Yes/No)
  random-retire              ; random likelihood that a farmer agent will want to retire (used for model diversity)
  farmer-enviro-aware        ; if the farmer is educated on environmental concerns

  ;; Economic attributes

  farm-production-type       ; whether a farm is classified as medium or large
  farm-business-type         ; represents the different types of farming (arable, dairy, poultry, etc.)
  farm-income                ; the net income associated with each individual farm
  farm-income-ha             ; the income each farm generates per hectare of land
  farm-fixed-costs-ha        ; the fixed costs each farm incurs
  farm-land-tenure           ; if the land is owned or rented by the farmer
  farm-investment            ; the amount each farmer invests in thier business
  farm-savings               ; the amount of savings each farmer has in the bank
  field-number               ; number of fields belonging to each farm

  ;; Policy attributes

  random-bioenergy           ; random number that determines farmer agent responsiveness to bioenergy policy
  random-agroforestry        ; random number that determines farmer agent responsiveness to agroforestry policy
  p-bioenergy                ; probability to adopt bioenergy policy (fixed)
  p-agroforestry             ; probability to adopt agroforestry policy (fixed)
  p-bio                      ; probability to adopt bioenergy policy (varies with model parameters)
  p-agro                     ; probability to adopt agroforestry policy (varies with model parameters)
  participated-in-scheme1    ; if the farmer agent decided to adopt the agroforestry policy
  participated-in-scheme2    ; if the farmer agent decided to adopt the bioenergy policy
  policy-agreement-years     ; number years since the farmer last made a decision of environmental schemes

  ;; Network attributes

  bio-neighbour              ; the number of link neighbours that took part in the bioenergy scheme
  agro-neighbour             ; the number of link neighbours that took part in the agroforestry scheme

  ;; Expansion attributes

  buyer-location             ; the location of a farm relative to the for sale property
  buyer-size                 ; the size of a farm relative to the for sale property
  buyer-group                ; different farmer groups are more/less likely to be interested in acquiring more lanf
  buyer-age                  ; age of the farmer is important in deciding on whether to expand the business
  buyer-savings              ; the amount of savings the farmer has in the bank will increase thier likelihood to buy
  buyer-total                ; the total value of all other factors that determine which farm buys the farm for sale
]

to setup
  clear-all

  load-map            ; sets up the spatial environment, combining the land use map with boundary data
  land-use-colours    ; assigns colours to represent different land cover classifications

  ; variables for showing/hiding farms initally set to true
  set view-traditional-farms? true
  set view-commercial-farms? true
  set view-supplementary-farms? true

  ; variables for showing/hiding links initally set to true
  set view-traditional-links? true
  set view-commercial-links? true
  set view-supplementary-links? true

  ; initialising the two varibales as lists
  set agro-list []
  set bio-list []
end

to setup-scenarios
  ; setting inital values for global attributes
  set county-selected ""
  set number-farms-county 0
  set number-farms-total number-farmers-initial

  ; agent implementation
  add-farmers
  farmer-attributes

  ; scenario implementation
  policy-responsiveness-random
  policy-farmer-type

  ; network implementation
  if(network-influence? = True) [
    farmer-network-influence
  ]

  ; plot updates
  update-plot

  reset-ticks
end

to go
  agroforestry-scenario-probability      ; likelihood to adopt agroforestry policy, influenced by agro payment rate
  bioenergy-crops-scenario-probability   ; likelihood to adopt bioenergy policy, influenced by bio payment rate

  update-farmer                          ; updating each farmer agent, occurs annually at each time step
  farmer-policy-decisions                ; farmer agent decision-making process

  update-values            ; updating spatial values
  update-plot              ; updating each of the plots

  if (ticks = 30)          ; the period modelled is 2020 - 2050
      [ stop ]             ; the model stops after 30 years

  tick                     ; one time step / one year
end

;;;;;;;;;;;;;;;;;;;;;
;;Spatial sub-model;;
;;;;;;;;;;;;;;;;;;;;;

to load-map
  ; loads a new global projection used for projecting GIS data as loaded from the file
  gis:load-coordinate-system ("projection/landUse.prj")

  ; loads the raster and vector datasets
  set land-use-map gis:load-dataset input-raster
  set antrim gis:load-dataset "boundary_data/antrim.shp"
  set down gis:load-dataset "boundary_data/down.shp"
  set tyrone gis:load-dataset "boundary_data/tyrone.shp"
  set londonderry gis:load-dataset "boundary_data/londonderry.shp"
  set armagh gis:load-dataset "boundary_data/armagh.shp"
  set fermanagh gis:load-dataset "boundary_data/fermanagh.shp"

  ; changes the size of the patch grid
  resize-world 0 gis:width-of land-use-map + 30 0 gis:height-of land-use-map + 30

  ; sets the transformation by mapping the envelope of the netlogo world to the given envelope in GIS space
  gis:set-world-envelope-ds (gis:envelope-union-of (gis:envelope-of land-use-map)
    (gis:envelope-of antrim)
    (gis:envelope-of down)
    (gis:envelope-of tyrone)
    (gis:envelope-of armagh)
    (gis:envelope-of londonderry)
    (gis:envelope-of fermanagh))

  ; copies values from the land-use-map raster dataset to land-use patch variable
  gis:apply-raster land-use-map land-use

  ; reports a list of all vector features in the antrim dataset
  foreach gis:feature-list-of antrim [
    gis:set-drawing-color white  ; sets the colour white to be used to draw the antrim vector data
    gis:draw antrim 1.0          ; draws the vector data using the drawing color and line thickness
  ]

  ; reports a list of all vector features in the down dataset
  foreach gis:feature-list-of down [
    gis:set-drawing-color white  ; sets the colour white to be used to draw the down vector data
    gis:draw down 1.0            ; draws the vector data using the drawing color and line thickness
  ]

  ; reports a list of all vector features in the tyrone dataset
  foreach gis:feature-list-of tyrone [
    gis:set-drawing-color white  ; sets the colour white to be used to draw the tyrone vector data
    gis:draw tyrone 1.0          ; draws the vector data using the drawing color and line thickness
  ]

  ; reports a list of all vector features in the armagh dataset
  foreach gis:feature-list-of armagh [
    gis:set-drawing-color white  ; sets the colour white to be used to draw armagh the vector data
    gis:draw armagh 1.0          ; draws the vector data using the drawing color and line thickness
  ]

  ; reports a list of all vector features in the londonderry dataset
  foreach gis:feature-list-of londonderry [
    gis:set-drawing-color white  ; sets the colour white to be used to draw the londonderry vector data
    gis:draw londonderry 1.0     ; draws the vector data using the drawing color and line thickness
  ]

  ; reports a list of all vector features in the fermanagh dataset
  foreach gis:feature-list-of fermanagh [
    gis:set-drawing-color white  ; sets the colour white to be used to draw the fermanagh vector data
    gis:draw fermanagh 1.0       ; draws the vector data using the drawing color and line thickness
  ]

  ; reports true if a patch intersects the county antrim vector data
  ask patches gis:intersecting antrim [ set inAntrim? True ]

  ; reports true if a patch intersects the county down vector data
  ask patches gis:intersecting down [ set inDown? True ]

  ; reports true if a patch intersects the county armagh vector data
  ask patches gis:intersecting armagh [ set inArmagh? True ]

  ; reports true if a patch intersects the county tyrone vector data
  ask patches gis:intersecting tyrone [ set inTyrone? True ]

  ; reports true if a patch intersects the county fermanagh vector data
  ask patches gis:intersecting fermanagh [ set inFermanagh? True ]

  ; reports true if a patch intersects the county londonderry vector data
  ask patches gis:intersecting londonderry [ set inLondonderry? True ]
end

to land-use-colours
  ; patches of different land-use are set different colours and land-cover classifications
  ask patches [
    if land-use = 1 [ set pcolor 15 set land-cover "forest"]       ; red = Broadleaf woodland
    if land-use = 2 [ set pcolor 15 set land-cover "forest"]       ; red = Coniferous woodland
    if land-use = 3 [ set pcolor 35 set land-cover "agriculture"]  ; brown = Arable
    if land-use = 4 [ set pcolor 55 set land-cover "agriculture"]  ; green = Improved grassland
    if land-use = 5 [ set pcolor 65 set land-cover "agriculture"]  ; lime green = Semi-natural grassland
    if land-use = 6 [ set pcolor 115 set land-cover "mountain"]    ; purple = Mountain, heath, bog
    if land-use = 7 [ set pcolor 105 set land-cover "water"]       ; blue = Freshwater/Saltwater
    if land-use = 8 [ set pcolor 105 set land-cover "water"]       ; blue = Freshwater/Saltwater
    if land-use = 9 [ set pcolor 45 set land-cover "coastal"]      ; yellow = Coastal
    if land-use = 10 [ set pcolor 05 set land-cover "urban"]       ; grey = Urban/Suburban
  ]
end

to farms-in-county
  ; asks the patch at mouse coordinates selected by the user to report the county selected and the number of farms in that county
  ask patch mouse-xcor mouse-ycor [
    if inAntrim? = true [set county-selected "Antrim" set number-farms-county (count turtles-on patches with [inAntrim? = True])]
    if inDown? = true [ set county-selected "Down" set number-farms-county (count turtles-on patches with [inDown? = True])]
    if inTyrone? = true [ set county-selected "Tyrone" set number-farms-county (count turtles-on patches with [inTyrone? = True])]
    if inLondonderry? = true [ set county-selected "Londonderry" set number-farms-county (count turtles-on patches with [inLondonderry? = True])]
    if inArmagh? = true [ set county-selected "Armagh" set number-farms-county (count turtles-on patches with [inArmagh? = True])]
    if inFermanagh? = true [ set county-selected "Fermanagh" set number-farms-county (count turtles-on patches with [inFermanagh? = True])]
  ]
end

to info
  ; displays the name of the county that the user's mouse selects and the number of farms within the county
  if mouse-down? [farms-in-county]
  display
end

;;;;;;;;;;;;;;;;;;;;
;;Social sub-model;;
;;;;;;;;;;;;;;;;;;;;

to add-farmers
  ; any patch not black that is classified as agricultural land is given a belong-to attribute
  ; initally set to nobody but is updated through the farmer land allocation process
  ask patches [if pcolor != black and land-cover = "agriculture" [ set belong-to nobody ]]

  ; number of agents belonging to each group depends on values obtained from the sliders set by the user
  set farms-traditional (round(number-farms-total * (tradition / 100)))
  set farms-commercial (round(number-farms-total * (commerc / 100)))
  set farms-supplementary (round(number-farms-total * (supplem / 100)))

  ; creates the traditional farmers and sets given amounts of them to different business types
  ; these farmers are represented in the model using a white dot
  create-traditionalists (farms-traditional) [
    set color white set size 3 set shape "dot"
    ask n-of (count traditionalists * 0.56) traditionalists [ set farm-business-type "Dairy"]
    ask n-of (count traditionalists * 0.20) traditionalists [ set farm-business-type "Cattle/Sheep"]
    ask n-of (count traditionalists * 0.08) traditionalists [ set farm-business-type "Poultry"]
    ask n-of (count traditionalists * 0.03) traditionalists [ set farm-business-type "Pigs"]
    ask n-of (count traditionalists * 0.07) traditionalists [ set farm-business-type "Arable"]
    ask n-of (count traditionalists * 0.06) traditionalists [ set farm-business-type "Other"]
  ]

  ; creates the commercial farmers and sets given amounts of them to different business types
  ; these farmers are represented in the model using a black dot
  create-commercials (farms-commercial) [
    set color black set size 3 set shape "dot"
    ask n-of (count commercials * 0.56) commercials [ set farm-business-type "Dairy"]
    ask n-of (count commercials * 0.20) commercials [ set farm-business-type "Cattle/Sheep"]
    ask n-of (count commercials * 0.08) commercials [ set farm-business-type "Poultry"]
    ask n-of (count commercials * 0.03) commercials [ set farm-business-type "Pigs"]
    ask n-of (count commercials * 0.07) commercials [ set farm-business-type "Arable"]
    ask n-of (count commercials * 0.06) commercials [ set farm-business-type "Other"]
  ]

  ; creates the supplementary farmers and sets given amounts of them to different business types
  ; these farmers are represented in the model using a pink dot
  create-supplementaries (farms-supplementary) [
    set color pink set size 3 set shape "dot"
    ask n-of (count supplementaries * 0.56) supplementaries [ set farm-business-type "Dairy"]
    ask n-of (count supplementaries * 0.20) supplementaries [ set farm-business-type "Cattle/Sheep"]
    ask n-of (count supplementaries * 0.08) supplementaries [ set farm-business-type "Poultry"]
    ask n-of (count supplementaries * 0.03) supplementaries [ set farm-business-type "Pigs"]
    ask n-of (count supplementaries * 0.07) supplementaries [ set farm-business-type "Arable"]
    ask n-of (count supplementaries * 0.06) supplementaries [ set farm-business-type "Other"]
  ]

  ask traditionalists [
    hide-turtle

    ; years since last decision is randomised between 1 and 10
    set policy-agreement-years random 10

    ; traditional agents move to patch that belongs to no other agent
    ; they are allocated land in a random radius up to 2
    ; this represents the farm that is owned by the farmer
    move-to one-of patches with [ belong-to = nobody]
    set field-number patches in-radius (random 2) with [ belong-to = nobody ]

    ; fields owned by the farm are set belonging to the group the farmer is a part of
    ; the fields are given an id to uniquely identify the farmer that owns them
    ask field-number [
      set belong-to "traditionalists"
      set field-owner-id myself
    ]
    set farm-size count field-number         ; farm size is determined by counting the field number (number of patches)
    set farm-size-hectares (farm-size * 50)  ; farm size is multiplied by 50 to give the farm size in hectares
  ]

  ask commercials [
    hide-turtle

    ; years since last decision is randomised between 1 and 10
    set policy-agreement-years random 10

    ; commercial agents move to patch that belongs to no other agent
    ; they are allocated land in a random radius up to 2
    ; this represents the farm that is owned by the farmer
    move-to one-of patches with [ belong-to = nobody]
    set field-number patches in-radius (random 2) with [ belong-to = nobody ]

    ; fields owned by the farm are set belonging to the group the farmer is a part of
    ; the fields are given an id to uniquely identify the farmer that owns them
    ask field-number [
      set belong-to "commercials"
      set field-owner-id myself
    ]
    set farm-size count field-number         ; farm size is determined by counting the field number (number of patches)
    set farm-size-hectares (farm-size * 50)  ; farm size is multiplied by 50 to give the farm size in hectares
  ]

  ask supplementaries [
    hide-turtle

    ; years since last decision is randomised between 1 and 10
    set policy-agreement-years random 10

    ; supplementary agents move to patch that belongs to no other agent
    ; they are allocated land in a random radius up to 2
    ; this represents the farm that is owned by the farmer
    move-to one-of patches with [ belong-to = nobody]
    set field-number patches in-radius (random 2) with [ belong-to = nobody ]

    ; fields owned by the farm are set belonging to the group the farmer is a part of
    ; the fields are given an id to uniquely identify the farmer that owns them
    ask field-number [
      set belong-to "supplementaries"
      set field-owner-id myself
    ]
    set farm-size count field-number         ; farm size is determined by counting the field number (number of patches)
    set farm-size-hectares (farm-size * 50)  ; farm size is multiplied by 50 to give the farm size in hectares
  ]

  ; reports a user error message if the condition is met
  if tradition + commerc + supplem != 100 [user-message "Ensure the percentage of farmer types adds up to 100%"]
end

to farmer-attributes
  ask turtles [
    ; research found the average age of a Northern Irish farmer is 59 years old
    let average-age-farmer 59

    ; age is distributed randomly using the average age and a standard-deviation of 10
    set farmer-age random-normal average-age-farmer 10

    set farmer-id who  ; farmer-id is set to the built-in turtle who number
    set random-retire random-float 1 ; agents are given a random likelihood that they will retire

    ; fixed costs per hectare are distributed randomly using an average obtained from empirical data
    set farm-fixed-costs-ha (ifelse-value
      (farm-business-type = "Dairy") [random-normal 890 300]
      (farm-business-type = "Cattle/Sheep") [random-normal 450 200]
      (farm-business-type = "Poultry") [random-normal 1000 300]
      (farm-business-type = "Pigs") [random-normal 2750 500]
      (farm-business-type = "Arable") [random-normal 930 300]
      [random-normal 900 300])

    ; savings are randomly distributed using the average value obtained from the slider
    set farm-savings random-normal avg-savings 5000

    ; farm business investment is randomly distributes using the average value obtained from the slider
    set farm-investment random-normal avg-investment 5000

    ; sets the production scale of the farm depending if it is more or less than 100 hectares
    ; due to temporal scales only medium/large farms exist
    ifelse(farm-size-hectares > 100)
    [set farm-production-type "Large"]
    [set farm-production-type "Medium"]

    ; incomes are randomly distributed using the average values obtained from the sliders
    ; incomes have a standard-deviation of £10,000 to encourage diversification
    let dairy-income random-normal avg-dairy-income 5000
    let cattle/sheep-income random-normal avg-cattle/sheep-income 5000
    let poultry-income random-normal avg-poultry-income 5000
    let pigs-income random-normal avg-pigs-income 5000
    let arable-income random-normal avg-arable-income 5000
    let other-income random-normal avg-other-income 5000

    ; farm income depends on the farm business the agents operate
    set farm-income (ifelse-value
      (farm-business-type = "Dairy") [dairy-income]
      (farm-business-type = "Cattle/Sheep") [cattle/sheep-income]
      (farm-business-type = "Poultry") [poultry-income]
      (farm-business-type = "Pigs") [pigs-income]
      (farm-business-type = "Arable") [arable-income]
      [other-income])

    if(farm-production-type = "Medium") [
      set farm-income (farm-income / 2)
    ]

    ; income per hectare is calculated by dividing the farm income by the farm size in hectares
    set farm-income-ha (ifelse-value
      (farm-business-type = "Dairy") [dairy-income / farm-size-hectares]
      (farm-business-type = "Cattle/Sheep") [cattle/sheep-income / farm-size-hectares]
      (farm-business-type = "Poultry") [poultry-income / farm-size-hectares]
      (farm-business-type = "Pigs") [pigs-income / farm-size-hectares]
      (farm-business-type = "Arable") [arable-income / farm-size-hectares]
      [other-income / farm-size-hectares])

    if(farm-production-type = "Medium") [
      set farm-income-ha (farm-income-ha / 2)
    ]

    if(farm-production-type = "Large") [
      set farm-income-ha (farm-income-ha * farm-size )
    ]
  ]

  ; sets the number of farmers with/without a successor to inherit the farrm
  ask turtles [set farm-successor false]
  ask n-of (farmers-with-successor * count turtles) turtles [set farm-successor true]

  ; sets the number of farmers with entirely owner-occupied land or rented land
  ask turtles [set farm-land-tenure "owner"]
  ask n-of (farms-with-rented-land * count turtles) turtles [set farm-land-tenure "owner/rented"]

  ; sets the numbers of famers that are aware/unaware of environmental concerns
  ask turtles [set farmer-enviro-aware false]
  ask n-of ((enviro-education / 100) * count turtles) turtles [set farmer-enviro-aware true]
end

to update-farmer
  ask turtles [
    set farmer-age (farmer-age + 1)  ;updates the farmer age at each time step
    set policy-agreement-years (policy-agreement-years + 1)  ; adds one to the years since last decision

    ; counters for the number of farmer agents that have participated in either scheme
    set policy1-number (count turtles with [participated-in-scheme1 = "Yes"])
    set policy2-number (count turtles with [participated-in-scheme2 = "Yes"])

    ; if the agents adopt a scheme they are less likely to participate in the same scheme again
    ; the other policy may also become slightly more attractive
    if(participated-in-scheme1 = "Yes") [
      set p-agro (p-agro - 0.05)
      set p-bio (p-bio + 0.05)
    ]
    if(participated-in-scheme2 = "Yes") [
      set p-bio (p-bio - 0.05)
      set p-agro (p-agro + 0.05)
    ]

    if(participated-in-scheme1 = "Yes" and participated-in-scheme2 = "Yes") [
      set p-bio (p-bio - 0.10)
      set p-agro (p-agro - 0.10)
    ]

    ; the average death age choosen by the user is randomly distributed and differs for every agent
    ; if the farmer's age is greater than this they are considered to be dead
    if(farmer-age > (avg-death-age * random-normal 1 0.1)) and (farm-successor = True) [
      ; the farm is inherited by a chosen successor (most likely a member of the family)
      ; all farm/farmer attributes stay the same apart from age (successor shares same ideas as previous owner)
      set farmer-age 30
    ]
    if(farmer-age > (avg-death-age * random-normal 1 0.1)) and (farm-successor = False) [
      ; the farm has no successor in place and the farm is therefore put up for sale
      sell-farm
    ]

    ; farmer agents choose retirement if they are greater than or equal to the retirement age choosen by the user
    ; and thier likelihood to retire is greater than the random retirement value assigned to them
    ; if these conditions are not met the farmer will continue working as the farm head until death
    ifelse ((farmer-age >= retirement-age) and (farmer-retirement > random-retire)) [set farm-retirement True] [set farm-retirement False]

    ; if they retire with a successor in place the farm in inherited
    if(farm-retirement = True and farm-successor = True) [
      set farmer-age 30
    ]

    ; if they retire with no sucessor in place the farm is put up for sale
    if(farm-retirement = True and farm-successor = False) [
      sell-farm
    ]

    ; process in which to count the number of neighbours that participated in either scheme
    set agro-neighbour count link-neighbors with [participated-in-scheme1 = "Yes"]
    set bio-neighbour count link-neighbors with [participated-in-scheme2 = "Yes"]

    ; if the farmer agents have a certain number of neighbours participating in either scheme
    ; that particular scheme becomes more attractive to them
    if(agro-neighbour >= 1) [
      set p-agro (p-agro + neighbour-influence)
    ]
    if(bio-neighbour >= 1) [
      set p-bio (p-bio + neighbour-influence)
    ]

    ; if the farmer is aware of environmental concerns they are more likely to participate in schemes
    if(farmer-enviro-aware = true) [
      set p-agro (p-agro + 0.20)
      set p-bio (p-bio + 0.20)
    ]
  ]

  climate-change  ; updates the ecological sub-model

  graph-lists     ; updates the lists at every year (at each time step)
end

to sell-farm
  ; process in which farms are sold in the case the farmer retires or dies with no successor

  ; the farmers interested in buying a farm are choosen to be close to the farm for sale
  let interested-farmers min-n-of 5 turtles [distance myself]

  ask interested-farmers [
    ;expansion attributes are set to zero
    set buyer-location 0
    set buyer-group 0
    set buyer-size 0
    set buyer-age 0
    set buyer-savings 0

    ; introduced to represent a randomness factor to be considered in the buying process
    let buyer-random random-float 0.10

    ; the values used to determine a buyer are calculated
    if(farm-size-hectares >= [farm-size-hectares] of myself) [set buyer-size 0.20]  ; the farm is larger than the farm for sale
    if (distance myself < 10) [set buyer-location 0.20]                             ; the farmer is close to the farm for sale
    if(breed = Commercials) [set buyer-group 0.13]                                  ; commercials are likely to be most interested
    if(breed = Supplementaries) [set buyer-group 0.10]                              ; supplementaries are second most interested
    if(breed = Traditionalists) [set buyer-group 0.07]                              ; traditionalists are least likely
    if(farmer-age < 50) [set buyer-age 0.15]                                        ; expanding farm business more likely in younger farmers
    if(farm-savings > avg-savings) [set buyer-savings 0.20]                         ; farmers with more savings in better position to buy farm

    ; the values are summed to give a total buyer rating for each interested farmer agent
    set buyer-total (buyer-location + buyer-size + buyer-group + buyer-age + buyer-random)
  ]

  ; the buyer of the farm is choosen by selecting one agent with the highest buyer total value
  let farmer-expansion max-one-of interested-farmers [buyer-total]

  ; the information on field ownership is updated with the buyers details
  ask field-number [
    set field-owner-id ([field-owner-id] of farmer-expansion)
    set belong-to ([belong-to] of farmer-expansion)
  ]

  ; the agents details are updated to reflect the increase in the farm size through acquiring the new farm
  ask farmer-expansion [
    set field-number patches with [field-owner-id = [field-owner-id] of myself]
    set farm-size count field-number
    set farm-size-hectares (farm-size * 50)
  ]

  die  ; the previous farmer agent is removed from the model as a result or retirement or death without a successor
end

to visible-traditional-farms
  ask traditionalists [ set hidden? view-traditional-farms? ]
end

to visible-commercial-farms
  ask commercials [ set hidden? view-commercial-farms? ]
end

to visible-supplementary-farms
  ask supplementaries [ set hidden? view-supplementary-farms? ]
end

; method that the 'view traditional farmers' button calls to toggle showing or hiding traditional farms
to show-traditional-farms
  set view-traditional-farms? (not view-traditional-farms?)
  visible-traditional-farms
end

; method that the 'view commercial farmers' button calls to toggle showing or hiding commercial farms
to show-commercial-farms
  set view-commercial-farms? (not view-commercial-farms?)
  visible-commercial-farms
end

; method that the 'view supplementary farmers' button calls to toggle showing or hiding supplementary farms
to show-supplementary-farms
  set view-supplementary-farms? (not view-supplementary-farms?)
  visible-supplementary-farms
end

to update-values
  ; updates the total number of hectares belonging to each farmer group
  set supp-ha ((count patches with [belong-to = "supplementaries"]) * 50)
  set comm-ha ((count patches with [belong-to = "commercials"]) * 50)
  set trad-ha ((count patches with [belong-to = "traditionalists"]) * 50)

  ; calculates the number of hectares in environmental schemes and the total costs of the schemes
  set total-hectares (trees-planted-hectares + crops-planted-hectares)
  set total-cost ( (crops-planted-hectares * bio-payment-rate-ha) + (trees-planted-hectares * agro-payment-rate-ha) )
end

;;;;;;;;;;;;;;;;;;;;
;;Policy sub-model;;
;;;;;;;;;;;;;;;;;;;;

to base-scenario
  ; used to simulate land use changes in the event either of the policy scenarios aren't selected to be simulated
  ; based on current tree planting and energy crop planting rates for Northern Ireland
  ask n-of 5 patches [
    if(land-cover = "agriculture" and belong-to = nobody)
    [set pcolor red]
  ]
end

to policy-responsiveness-random
  ; farmer agents are first assigned a random likelihood that they will participate in either scheme
  ask turtles [
    set random-bioenergy random-float 1
    set random-agroforestry random-float 1
  ]
end

to policy-farmer-type
  ; agents from each of the three groups are given an initial likelihood to particpate in each of policies
  ; the values are taken from sliders with the value dependent on the group the agent is a part of

  ask traditionalists [
    set p-bioenergy trad-bio
    set p-agroforestry trad-agro
  ]

  ask commercials [
    set p-bioenergy comm-bio
    set p-agroforestry comm-agro
  ]

  ask supplementaries [
    set p-bioenergy supp-bio
    set p-agroforestry supp-agro
  ]
end

to agroforestry-scenario-probability
  ; initial value for agroforestry adoption is used to determine p-agro
  ; this value is the same initally but unlike the initial likelihood value p-agro is not fixed
  ; it is subject to change over time depending on other parameter inputs
  ; each group responds differently to changes in the agroforestry payment rate
  ; a multiplier might be applied to p-agro depending on the value taken from the agro payment rate slider

  ask commercials [
    ifelse(agro-payment-rate-ha > farm-income-ha)
    [set p-agro (p-agroforestry + 0.30)]
    [set p-agro (p-agroforestry)]
  ]

  ask traditionalists [
    ifelse(agro-payment-rate-ha > (farm-income-ha * 2))
    [set p-agro (p-agroforestry + 0.20)]
    [set p-agro (p-agroforestry)]
  ]

  ask supplementaries [
    ifelse(agro-payment-rate-ha > farm-income-ha)
    [set p-agro (p-agroforestry + 0.15)]
    [set p-agro (p-agroforestry)]
  ]
end

to bioenergy-crops-scenario-probability
  ; initial value for bioenergy adoption is used to determine p-bio
  ; this value is the same initally but unlike the initial likelihood value p-bio is not fixed
  ; it is subject to change over time depending on other parameter inputs
  ; each group responds differently to changes in the bioenergy crop payment rate
  ; a multiplier might be applied to p-bio depending on the value taken from the bioenergy payment rate slider

  ask commercials [
    ifelse(bio-payment-rate-ha > farm-income-ha)
    [set p-bio (p-bioenergy + 0.30)]
    [set p-bio (p-bioenergy)]
  ]

  ask traditionalists [
    ifelse(bio-payment-rate-ha > (farm-income-ha * 2))
    [set p-bio (p-bioenergy + 0.20)]
    [set p-bio (p-bioenergy)]
  ]

  ask supplementaries [
    ifelse(bio-payment-rate-ha > farm-income-ha)
    [set p-bio (p-bioenergy + 0.15)]
    [set p-bio (p-bioenergy)]
  ]
end

to farmer-policy-decisions
  ask turtles [

    ; farmers can adopt this policy if it has been 10 years since thier last decision as policy contracts last 10 years
    if policy-agreement-years >= 10 [

      ; if the agroforestry scenario is turned on farmer agents may make decisions on adopting this policy
      if agroforestry-policy? [
        ; if thier likelihood to participate is greater than thier random value they will adopt this policy
        if (p-agro > random-agroforestry) [

          ; a given percentage of thier farm is converted to agroforestry
          ask n-of (int (0.20 * farm-size)) patches with [field-owner-id = myself] [
            set land-cover "forest"  ; the classification changes to 'forest' with trees now present on land
            set pcolor red           ; the color of the field changes to red to visualise the conversion
          ]
          set policy-agreement-years 0       ; years since last decision is reset to 0
          set participated-in-scheme1 "Yes"  ; the farmer has adopted the agroforestry policy
        ]
      ]

      ; if the bioenergy scenario is turned on farmer agents may make decisions on adopting this policy
      if bioenergy-policy? [
        ; if thier likelihood to participate is greater than thier random value they will adopt this policy
        if ( p-bio > random-bioenergy) [

          ; a given percentage of thier farm is converted to bioenergy crops
          ask n-of (int (0.20 * farm-size)) patches with [field-owner-id = myself] [
            set land-cover "bioenergy crops" ; the classification changes to 'bioenergy crops' with crops now present on land
            set pcolor cyan                  ; the color of the field changes to cyan to visualise the conversion
          ]
          set policy-agreement-years 0       ; years since last decision is reset to 0
          set participated-in-scheme2 "Yes"  ; the farmer has adopted the bioenergy policy
        ]
      ]
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;
;;Ecological sub-model;;
;;;;;;;;;;;;;;;;;;;;;;;;

to climate-change
  ; counts the total hectares with a forest land cover classification belonging to either of three groups
  set trees-planted-hectares ((count patches with [ land-cover = "forest" and ( belong-to = "traditionalists" or belong-to = "commercials" or belong-to = "supplementaries")]) * 50)

  ; counts the total hectares with a bioenergy crop land cover classification belonging to either of three groups
  set crops-planted-hectares ((count patches with [ land-cover = "bioenergy crops" and ( belong-to = "traditionalists" or belong-to = "commercials" or belong-to = "supplementaries")]) * 50)

  set GHG-emissions-initial 7 ; measured in MtCO2e (7 Million tonnes CO2e)

  ; uses the planting density of trees per hectare and the sequestration rate of one tree
  ; to calculate the sequestration rate of agroforestry
  set agro-sequest-ha-mt (num-trees-ha * (tree-sequest-rate) / 1000000)

  ; calculates the percentage of bioenergy crops planted in short rotation coppice willow
  let willow-hectares (crops-planted-hectares * (willow-planted / 100))

  ; calculates the percentage of bioenergy crops planted in miscanthus
  let miscan-hectares (crops-planted-hectares * (miscanthus-planted / 100))

  ; calculates the sequestration rates of miscanthus and willow per hectare per year
  ; measured in MtCO2e
  let willow-sequest-ha-mt (willow-sequest-rate / 1000000)
  let miscan-sequest-ha-mt (miscan-sequest-rate / 1000000)

  ; reports a user error message if the condition is met
  if willow-planted + miscanthus-planted != 100 [user-message "Ensure the percentage of bioenergy crops planted adds up to 100%"]

  ; produces the total value for greenhouse gas emission reductions at each time step
  set GHG-reductions ((agro-sequest-ha-mt * trees-planted-hectares) + ((willow-sequest-ha-mt * willow-hectares) + (miscan-sequest-ha-mt * miscan-hectares)))
end

;;;;;;;;;;;;;;;;;;;;;
;;Network sub-model;;
;;;;;;;;;;;;;;;;;;;;;

to farmer-network-influence
  ; asks commercial farmer agents to make links with a number of neighbours taken from a slider
  ask commercials
  [
    create-links-with min-n-of comm-neighbours other commercials [distance myself] [hide-link]
  ]

  ; asks traditional farmer agents to make links with a number of neighbours taken from a slider
  ask traditionalists
  [
    create-links-with min-n-of trad-neighbours other traditionalists [distance myself] [hide-link]
  ]

  ; asks supplementary farmer agents to make links with a number of neighbours taken from a slider
  ask supplementaries
  [
    create-links-with min-n-of supp-neighbours other supplementaries [distance myself] [hide-link]
  ]
end

; traditional links are coloured yellow and initially hidden from user
to visible-traditional-links
  ask traditionalists [
    ask my-links [
      set hidden? view-traditional-links?
      set color yellow
    ]
  ]
end

; commercial links are coloured orange and initially hidden from user
to visible-commercial-links
  ask commercials [
    ask my-links [
      set hidden? view-commercial-links?
      set color orange
    ]
  ]
end

; supplementary links are coloured blue and initially hidden from user
to visible-supplementary-links
  ask supplementaries [
    ask my-links [
      set hidden? view-supplementary-links?
      set color blue
    ]
  ]
end

; method that the 'view traditional links' button calls to toggle showing or hiding traditional links
to show-traditional-links
  set view-traditional-links? (not view-traditional-links?)
  visible-traditional-links
end

; method that the 'view commercial links' button calls to toggle showing or hiding commercial links
to show-commercial-links
  set view-commercial-links? (not view-commercial-links?)
  visible-commercial-links
end

; method that the 'view supplementary links' button calls to toggle showing or hiding supplementary links
to show-supplementary-links
  set view-supplementary-links? (not view-supplementary-links?)
  visible-supplementary-links
end

;;;;;;;;;;
;;Output;;
;;;;;;;;;;

to update-plot
  ; plot of the number of hectares planted in agroforestry by each group
  set-current-plot "Agroforestry"
  set-current-plot-pen "Traditionalists"
  plot ((count patches with [land-cover = "forest" and belong-to = "traditionalists"]) * 50)
  set-current-plot-pen "Commercials"
  plot ((count patches with [land-cover = "forest" and belong-to = "commercials"]) * 50)
  set-current-plot-pen "Supplementaries"
  plot ((count patches with [land-cover = "forest" and belong-to = "supplementaries"]) * 50)

  ; plot of the number of hectares planted in bioenergy crops by each group
  set-current-plot "Bioenergy Crops"
  set-current-plot-pen "Traditionalists"
  plot ((count patches with [land-cover = "bioenergy crops" and belong-to = "traditionalists"]) * 50)
  set-current-plot-pen "Commercials"
  plot ((count patches with [land-cover = "bioenergy crops" and belong-to = "commercials"]) * 50)
  set-current-plot-pen "Supplementaries"
  plot ((count patches with [land-cover = "bioenergy crops" and belong-to = "supplementaries"]) * 50)

  ; plot of the greenhouse gas emission reductions as a result of policy intervention
  set-current-plot "Greenhouse Gas Emissions"
  set-current-plot-pen "Emissions"
  plot(GHG-emissions-initial - GHG-reductions)

  ; plot of the costs involved in introducing these agri-environmental schemes to farmers
  set-current-plot "Cost of EFS's"
  set-current-plot-pen "Bioenergy"
  plot(crops-planted-hectares * bio-payment-rate-ha)
  set-current-plot-pen "Agroforestry"
  plot(trees-planted-hectares * agro-payment-rate-ha)
end

;;;;;;;;;;;;;;;
;;r extension;;
;;;;;;;;;;;;;;;

to graph-lists
  ; puts the total hectares of agroforestry and bioenergy crops planted at the end of each year into a list
  set agro-list (lput ((count patches with [ land-cover = "forest" and ( belong-to = "traditionalists" or belong-to = "commercials" or belong-to = "supplementaries")]) * 50) agro-list)
  set bio-list (lput ((count patches with [ land-cover = "bioenergy crops" and ( belong-to = "traditionalists" or belong-to = "commercials" or belong-to = "supplementaries")]) * 50) bio-list)
end

to visualise-export-data
  r:put "agentlist1" agro-list  ; creates the variable agentlist1 in R, the value agro-list is a list
  r:put "agentlist2" bio-list   ; creates the variable agentlist2 in R, the value bio-list is a list

  print "create a plot into file..."

  let evalstring (word "jpeg('" plotfile ".jpeg')")  ; create a jpeg with the plot
  show evalstring
  r:eval evalstring

  ; assigns the plot data to the attributes xs1 and xs2
  r:eval "xs1 <- c(agentlist1)"
  r:eval "xs2 <- c(agentlist2)"

  ; creates the plot and adds the agroforestry (red) line, the xy-axis labels and the plot title
  r:eval "plot(xs1, type=\"l\", col=\"red\", xlab=\"Time (years)\", ylab=\"Hectares Planted (ha)\", main=\"Total Hectares Converted to Agroforestry and Bioenergy Crops \", ylim=c(0, ( 1.5 * max(agentlist1))))"

  ; adds the bioenergy (blue) line to the plot
  r:eval "lines(xs2, type=\"l\", col=\"blue\")"

  ; adds a legend to the plot which is placed at the top-left
  r:eval "legend(x=\"topleft\",legend=c(\"Agroforestry\",\"Bioenergy Crops\"),col=c(\"red\",\"blue\"), lty=1:1)"

  ; this function closes the plot
  r:eval "dev.off()"
end
@#$#@#$#@
GRAPHICS-WINDOW
789
10
1483
612
-1
-1
3.105
1
8
1
1
1
0
1
1
1
0
220
0
190
1
1
1
ticks
30.0

BUTTON
9
125
179
158
Setup Environment
setup\n
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
10
510
180
543
Get Information
info\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
10
605
180
650
Number of Farms
number-farms-county
17
1
11

MONITOR
11
550
180
595
Selected County
county-selected
17
1
11

BUTTON
10
216
74
249
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
207
122
369
155
tradition
tradition
0
100
35.0
1
1
%
HORIZONTAL

SLIDER
208
160
370
193
commerc
commerc
0
100
35.0
1
1
%
HORIZONTAL

BUTTON
81
216
179
249
Single Step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
1499
10
1754
160
Agroforestry
Time
Hectares
0.0
30.0
0.0
10.0
true
true
"" ""
PENS
"Commercials" 1.0 0 -2674135 true "" ""
"Traditionalists" 1.0 0 -13791810 true "" ""
"Supplementaries" 1.0 0 -13840069 true "" ""

SWITCH
397
58
567
91
agroforestry-policy?
agroforestry-policy?
0
1
-1000

SWITCH
398
98
568
131
bioenergy-policy?
bioenergy-policy?
0
1
-1000

BUTTON
10
177
179
210
Setup Scenarios
setup-scenarios
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1499
166
1755
316
Bioenergy Crops
Time
Hectares
0.0
30.0
0.0
10.0
true
true
"" ""
PENS
"Commercials" 1.0 0 -2674135 true "" ""
"Traditionalists" 1.0 0 -13791810 true "" ""
"Supplementaries" 1.0 0 -13840069 true "" ""

BUTTON
7
267
181
300
View Traditional Farmers
show-traditional-farms
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
7
304
182
337
View Commercial Farmers
show-commercial-farms
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

INPUTBOX
9
58
180
118
input-raster
QGIS_clip/landUse.asc
1
0
String

TEXTBOX
29
28
162
54
Spatial Sub-Model
14
0.0
1

TEXTBOX
224
26
355
44
Social Sub-Model
14
0.0
1

TEXTBOX
210
102
347
120
% of farm owner types
12
0.0
1

SLIDER
205
247
373
280
trad-bio
trad-bio
0
1
0.25
0.01
1
NIL
HORIZONTAL

SLIDER
205
284
374
317
trad-agro
trad-agro
0
1
0.28
0.01
1
NIL
HORIZONTAL

TEXTBOX
410
26
560
46
Economic Sub-Model
14
0.0
1

SLIDER
204
323
374
356
comm-bio
comm-bio
0
1
0.2
0.01
1
NIL
HORIZONTAL

SLIDER
204
360
374
393
comm-agro
comm-agro
0
1
0.2
0.01
1
NIL
HORIZONTAL

MONITOR
795
660
889
705
Agroforestry
policy1-number
17
1
11

MONITOR
902
660
996
705
Bioenergy
policy2-number
17
1
11

TEXTBOX
795
625
1000
655
Number of farms participating in each scheme
12
0.0
1

SLIDER
397
146
571
179
bio-payment-rate-ha
bio-payment-rate-ha
0
3000
590.0
10
1
£
HORIZONTAL

SLIDER
398
186
570
219
agro-payment-rate-ha
agro-payment-rate-ha
0
3000
1410.0
10
1
£
HORIZONTAL

BUTTON
7
340
182
373
View Supplementary Farmers
show-supplementary-farms
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
207
198
370
231
supplem
supplem
0
100
30.0
1
1
%
HORIZONTAL

SLIDER
203
399
375
432
supp-bio
supp-bio
0
1
0.33
0.01
1
NIL
HORIZONTAL

SLIDER
202
437
376
470
supp-agro
supp-agro
0
1
0.35
0.01
1
NIL
HORIZONTAL

PLOT
1500
325
1754
475
Greenhouse Gas Emissions
Time
MtCO2e
0.0
30.0
0.0
8.0
true
false
"" ""
PENS
"Emissions" 1.0 0 -16777216 true "" ""

SLIDER
397
238
575
271
avg-dairy-income
avg-dairy-income
0
200000
55000.0
5000
1
£
HORIZONTAL

SLIDER
396
277
575
310
avg-cattle/sheep-income
avg-cattle/sheep-income
0
200000
20000.0
5000
1
£
HORIZONTAL

SLIDER
396
316
575
349
avg-poultry-income
avg-poultry-income
0
200000
60000.0
5000
1
£
HORIZONTAL

SLIDER
395
355
575
388
avg-pigs-income
avg-pigs-income
0
200000
85000.0
5000
1
£
HORIZONTAL

SLIDER
395
433
575
466
avg-other-income
avg-other-income
0
200000
30000.0
5000
1
£
HORIZONTAL

SLIDER
396
394
575
427
avg-arable-income
avg-arable-income
0
200000
70000.0
5000
1
£
HORIZONTAL

SLIDER
201
488
376
521
farmers-with-successor
farmers-with-successor
0
1
0.75
0.01
1
NIL
HORIZONTAL

TEXTBOX
612
23
762
41
Ecological Sub-Model
14
0.0
1

SLIDER
597
227
782
260
miscan-sequest-rate
miscan-sequest-rate
0
50
15.0
0.50
1
tC02e
HORIZONTAL

SLIDER
595
55
780
88
num-trees-ha
num-trees-ha
0
300
150.0
5
1
NIL
HORIZONTAL

SLIDER
595
94
780
127
tree-sequest-rate
tree-sequest-rate
0
1
0.5
0.001
1
tC02e
HORIZONTAL

SLIDER
596
266
782
299
willow-sequest-rate
willow-sequest-rate
0
50
15.0
0.5
1
tC02e
HORIZONTAL

SLIDER
597
142
780
175
willow-planted
willow-planted
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
596
180
781
213
miscanthus-planted
miscanthus-planted
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
200
525
376
558
avg-death-age
avg-death-age
30
110
85.0
1
1
years
HORIZONTAL

BUTTON
7
388
181
421
View Traditional Links
show-traditional-links
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
8
426
181
459
View Commercial Links
show-commercial-links
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
9
464
182
497
View Supplementary Links
show-supplementary-links
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
200
565
376
598
farmer-retirement
farmer-retirement
0
1
0.2
0.01
1
NIL
HORIZONTAL

TEXTBOX
617
330
767
348
Network Sub-Model
14
0.0
1

PLOT
1502
484
1755
634
Cost of EFS's
TIme
Cost (£)
0.0
30.0
0.0
10.0
true
true
"" ""
PENS
"Bioenergy" 1.0 0 -11221820 true "" ""
"Agroforestry" 1.0 0 -2674135 true "" ""

SLIDER
200
604
377
637
retirement-age
retirement-age
30
110
65.0
1
1
years
HORIZONTAL

SLIDER
207
57
370
90
number-farmers-initial
number-farmers-initial
0
3000
500.0
1
1
NIL
HORIZONTAL

SLIDER
200
642
378
675
farms-with-rented-land
farms-with-rented-land
0
1
0.49
0.01
1
NIL
HORIZONTAL

SLIDER
594
400
782
433
supp-neighbours
supp-neighbours
0
10
2.0
1
1
NIL
HORIZONTAL

SLIDER
594
437
782
470
trad-neighbours
trad-neighbours
0
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
594
474
781
507
comm-neighbours
comm-neighbours
0
10
6.0
1
1
NIL
HORIZONTAL

SLIDER
201
681
378
714
enviro-education
enviro-education
0
100
30.0
1
1
%
HORIZONTAL

SLIDER
396
477
576
510
avg-savings
avg-savings
0
200000
40000.0
5000
1
£
HORIZONTAL

SLIDER
396
516
576
549
avg-investment
avg-investment
0
200000
50000.0
5000
1
£
HORIZONTAL

SWITCH
594
355
781
388
network-influence?
network-influence?
0
1
-1000

SLIDER
595
512
781
545
neighbour-influence
neighbour-influence
0
1
0.15
0.01
1
NIL
HORIZONTAL

MONITOR
1162
659
1228
704
NIL
supp-ha
17
1
11

MONITOR
1014
659
1082
704
NIL
trad-ha
17
1
11

MONITOR
1090
659
1156
704
NIL
comm-ha
17
1
11

TEXTBOX
1014
623
1226
653
Number of hectares belonging to each group
12
0.0
1

BUTTON
541
574
694
607
Choose File
set plotfile user-new-file
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
542
613
696
673
plotfile
/Users/jp/Desktop/Untitled
1
0
String

BUTTON
543
680
697
713
Export Output
visualise-export-data
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
477
633
532
651
Output:
14
14.0
1

@#$#@#$#@
## WHAT IS IT?

This purpose of this model is to simulate the impact of agri-environmental schemes on land-use. Land-use conversions are determined by the adoption decisions of farmers in response to different policy scenarios.

Policy scenarios are introduced with clearly defined target outcomes for the environment to meet UK-wide emission targets. Greenhouse gas emission reductions as a result of land-use changes will be monitored in the model to determine the success of policy intervention.

The model intends to serve as a tool to be used by policymakers to help support policy design by allowing predictive evaluation of sustainable schemes before implementation to avoid unintended consequences.


## HOW TO USE IT

#### Setting up spatial environment

To interact with the model, first, you have to create the environment. Ensure you download both the GIS land-use map and vector boundary data with the correct path to file set for all. You will be unable to run the model if these are not correct. Then, click on the 'setup environment' button and you should see the GIS land-use map for Northern Ireland.

#### Creating the farmer agents

The second step before running the simulation is to add the farm owners to the spatial landscape. Under the social sub-model, first, select the total number of farmers you want to simulate. Next, choose the percentages of different farm owner types. These must add up to 100% otherwise an error message is returned. Now, choose the likelihood that each of the farmer groups adopts either of the environmental schemes. This can be done by adjusting the next six sliders under the social sub-model (comm-bio, trad-agro, etc).


#### Adjusting the policy scenarios

The economic sub-model holds different options for policy schemes. You can choose to run the model with the agroforestry and bioenergy policy scenarios turned on or off. In the case that the model is run with either scenario turned off a base scenario is run which is based on current empirical data for land-use changes. You can change the various other sub-model parameters if you wish to run the model under different conditions and incentives. 

#### Monitoring the greenhouse gas reductions

Model parameters under the ecological sub-model can be adjusted by you to impact the reductions in greenhouse gas emissions over the 30-year timeframe. Changing the planting density of trees per hectare and the sequestration rate of one tree will vary the amount of carbon removed from the atmosphere per hectare per year. Changing the percentages of bioenergy crops planted in either willow or miscanthus and their respective sequestration rates will vary the amount of carbon removed from the atmosphere per hectare per year. The percentages of willow and miscanthus planted must add up to 100% otherwise an error message is returned.

#### Changing the influence of farmer networks 

Each of the three groups belongs to a social network with other members of that same group. You can vary the number of neighbours each member of each group has. You can also choose to run the model with or without the influence of networks so you can see easily the effects of being influenced by the policy decisions of neighbours. The extent each farmer is influenced by their neighbours' decisions can also be adjusted by you. 

#### Starting a single model run 

Once you are happy with the input parameters you are ready to start the model. Press 'setup scenarios' and then either 'go' or 'single step'. 'go' is a forever button and when pressed will keep going at each time step (one year) until the simulation is complete. 'single step' will run the model for one tick stopping at the end of each time step. One run of the simulation last 30 ticks which represents 30 years as the period being modelled is 2020 to 2050.

## THINGS TO NOTICE

To reset the model for another simulation you must always press 'setup environment', then 'setup scenarios' before pressing either 'go' or 'single step'

To run experiments with the model you will need to use NetLogo's built-in behaviour space tool 

When the model is running you can view each of the four plots that measure the number of hectares converted to agroforestry and bioenergy crops, the reductions in greenhouse gas emissions and the total costs involved in implementing these schemes.

You can also view the number of farms that participated in either scheme or the total hectares of agricultural land belonging to each farmer group using the monitors

Pressing the view farmers or view links buttons will reveal the locations of the farmers' agents and the links that exist between them. These buttons will only work if they 'setup scenarios' button has been pressed 

Pressing the 'get information' button will allow you to click your mouse anywhere on the land-use map and receive the county you selected and the number of farms with land in that county

## FURTHER DETAILS

If you have any questions or queries, please contact John Poole
 (johnpoole329@gmail.com)

Project supervised by Dr Savi Maharaj
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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
setup
display-cities
display-countries
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="ecological-model-1" repetitions="5" runMetricsEveryStep="false">
    <setup>setup
setup-scenarios</setup>
    <go>go</go>
    <metric>GHG-emissions-initial - GHG-reductions</metric>
    <steppedValueSet variable="num-trees-ha" first="0" step="50" last="300"/>
  </experiment>
  <experiment name="ecological-model-2" repetitions="5" runMetricsEveryStep="false">
    <setup>setup
setup-scenarios</setup>
    <go>go</go>
    <metric>GHG-emissions-initial - GHG-reductions</metric>
    <steppedValueSet variable="tree-sequest-rate" first="0" step="0.2" last="1"/>
  </experiment>
  <experiment name="ecological-model-3" repetitions="5" runMetricsEveryStep="false">
    <setup>setup
setup-scenarios</setup>
    <go>go</go>
    <metric>GHG-emissions-initial - GHG-reductions</metric>
    <steppedValueSet variable="miscan-sequest-rate" first="0" step="10" last="50"/>
    <steppedValueSet variable="willow-sequest-rate" first="0" step="10" last="50"/>
  </experiment>
  <experiment name="economic-model-1" repetitions="10" runMetricsEveryStep="false">
    <setup>setup
setup-scenarios</setup>
    <go>go</go>
    <metric>trees-planted-hectares</metric>
    <steppedValueSet variable="agro-payment-rate-ha" first="0" step="500" last="3000"/>
  </experiment>
  <experiment name="economic-model-2" repetitions="10" runMetricsEveryStep="false">
    <setup>setup
setup-scenarios</setup>
    <go>go</go>
    <metric>crops-planted-hectares</metric>
    <steppedValueSet variable="bio-payment-rate-ha" first="0" step="500" last="3000"/>
  </experiment>
  <experiment name="social-model-1" repetitions="5" runMetricsEveryStep="false">
    <setup>setup
setup-scenarios</setup>
    <go>go</go>
    <metric>trees-planted-hectares + crops-planted-hectares</metric>
    <steppedValueSet variable="enviro-education" first="0" step="20" last="100"/>
  </experiment>
  <experiment name="social-model-2" repetitions="5" runMetricsEveryStep="false">
    <setup>setup
setup-scenarios</setup>
    <go>go</go>
    <metric>trees-planted-hectares + crops-planted-hectares</metric>
    <steppedValueSet variable="farmers-with-successor" first="0" step="0.2" last="1"/>
  </experiment>
  <experiment name="network-model-1" repetitions="5" runMetricsEveryStep="false">
    <setup>setup
setup-scenarios</setup>
    <go>go</go>
    <metric>trees-planted-hectares + crops-planted-hectares</metric>
    <steppedValueSet variable="neighbour-influence" first="0" step="0.2" last="1"/>
  </experiment>
  <experiment name="network-model-2" repetitions="5" runMetricsEveryStep="false">
    <setup>setup
setup-scenarios</setup>
    <go>go</go>
    <metric>trees-planted-hectares + crops-planted-hectares</metric>
    <enumeratedValueSet variable="network-influence?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="network-model-3" repetitions="10" runMetricsEveryStep="false">
    <setup>setup
setup-scenarios</setup>
    <go>go</go>
    <metric>trees-planted-hectares + crops-planted-hectares</metric>
    <steppedValueSet variable="comm-neighbours" first="0" step="2" last="10"/>
  </experiment>
  <experiment name="study-experiment" repetitions="5" runMetricsEveryStep="false">
    <setup>setup
setup-scenarios</setup>
    <go>go</go>
    <metric>total-hectares</metric>
    <metric>total-cost</metric>
    <enumeratedValueSet variable="agro-payment-rate-ha">
      <value value="500"/>
      <value value="1000"/>
      <value value="1500"/>
      <value value="2000"/>
      <value value="2500"/>
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bio-payment-rate-ha">
      <value value="500"/>
      <value value="1000"/>
      <value value="1500"/>
      <value value="2000"/>
      <value value="2500"/>
      <value value="3000"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="study-experiment-runtime" repetitions="5" runMetricsEveryStep="true">
    <setup>setup
setup-scenarios</setup>
    <go>go</go>
    <metric>total-hectares</metric>
    <metric>total-cost</metric>
    <steppedValueSet variable="agro-payment-rate-ha" first="500" step="500" last="3000"/>
    <steppedValueSet variable="bio-payment-rate-ha" first="500" step="500" last="3000"/>
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
