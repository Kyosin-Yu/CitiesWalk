**GROUP CONTRACT FORM** 



**FACULTY : FACULTY OF COMPUTING AND INFORMATION TECHNOLOGY (FOCS) COURSE CODE / NAME : BMSE2073 SOFTWARE DESIGN AND ARCHITECTURE PROGRAMME : RSW2S3G3 SEMESTER : 202601 COURSE CODE / TITLE : BMSE3004 COLLABORATIVE DEVELOPMENT PROJECT TITLE : CitiesWalk PRACTICAL GROUP : RSW2S3G3 TUTOR NAME : MUHAMMAD IRSYAD BIN KAMIL RIADZ** 

|**NAME (BLOCK LETTERS)**|**ROLE & MODULE**<br>**ASSIGNED**|**STUDENT ID.**|**SIGNATU**<br>**RE &**<br>**DATE**|
|---|---|---|---|
|1.  CHUA THIAM POH|Role:  Project Manager<br>Module : Eco-Route Planner|24WMR14290|25/6/2026|
|2. KOH HUAI YU|Role:  Requirement Lead<br>Module : Eco-Fitness & Carbon<br>Analytics Module|24WMR14303|25/6/2026|
|3. TAN YAN ZUN|Role:  Testing Lead<br>Module : Rewards & Leaderboard<br>Module|24WMR14349|25/6/2026|
|4. LAI YU WAI|Role:  Design Lead<br>Module : User Management &<br>Authentication Module|24WMR14304|25/6/2026|
|5. ENG ZHEN XIN|Role:  Coding/Development<br>Module : Community Review &<br>Rating Module|24WMR14293|25/6/2026|



**AI USAGE DISCLOSURE FORM** 



##### **STUDENT :** 

|**NAME(BLOCK LETTERS)**|**STUDENT ID.**|
|---|---|
|**1.  CHUA THIAM POH**|**24WMR14290**|
|**2. KOH HUAI YU**|**24WMR14303**|
|**3. TAN YAN ZUN**|**24WMR14349**|
|**4. LAI YU WAI**|**24WMR14304**|
|**5. ENG ZHEN XIN**|**24WMR14293**|



##### **PROGRAMME : RSW2S3G3 COURSE : BMSE3004 Collaborative PROJECT TITLE : CitiesWalk** 

##### **1. AI Tool(s) Used (Check that all that apply)** 

- [ ] None (I/We did not use any AI tools for this assignment) 

[     /      ] ChatGPT (Version: ________) [ ] Deepseek [     /      ] Gemini [ ] 

Other: ________________ 

##### 2. **Nature of Assistance (Check all that apply)** 

- [      /     ] **Brainstorming:** Generating ideas, topics, or outlines. 

- [     /      ] **Research:** Summarising long articles or finding concepts. 

- [     /      ] **Editing:** Checking grammar, spelling, or sentence structure. 

- [     /      ] **Coding/Math:** Debugging code or explaining a formula. 

- [     /      ] **Creation:** Generating images, data, or draft text 

##### 3. **Disclosure Statement** 

_Provide a brief explanation of how AI tools were utilised in completing the task and describe the measures taken to ensure that the final submission reflects your own or your group independent work_ 

Gemini was utilized as a supportive tool to refine the structural layout of the system architecture and optimize the project timeline. The final CitiesWalk proposal reflects our independent engineering decisions, as all technical designs and functional requirements were entirely conceptualized and verified by the team. 

##### 4. **Verification & Integrity** 

- [     /    ] I/We have reviewed and verified the accuracy of all facts, data, and citations generated with the assistance of AI tools. 

- [   /   ] I/We have properly acknowledged and cited any AI-generated text, ideas, or content in accordance with my instructor’s requirements. 

- [     /    ] I confirm that the reasoning, interpretation, and analysis presented in the final submission are entirely my own 

**Student / Group Representative Signature:** 



**Date: 26/6/2026** 

_AMM 5.3.2026/SMC 1.4.2026_ 



# PROJECT PROPOSAL 

PROJECT TITLE : CITIESWALK 

**PROJECT PROPOSAL** 

## **<mark>TABLE OF CONTENTS</mark>** 

|**TABLE OF CONTENTS................................................................................................................................................2**|
|---|
|**1.  Introduction........................................................................................................................................................3**|
|1.1 Background Study................................................................................................................................3|
|1.2 Project Description...............................................................................................................................5|
|1.3 UN SDG and Justification.................................................................................................................... 7|
|1.4 Existing Work.......................................................................................................................................8|
|1.4.1 Competitor Analysis.................................................................................................................... 9|
|Analysis of Market Gaps.................................................................................................................... 10|
|Conclusion..........................................................................................................................................11|
|1.5 Project Significance........................................................................................................................... 12|
|1.3 Background Study...............................................................................................................................................14|
|**2.  TEAM STRUCTURE & WORK PLAN..................................................................................................................... 16**|
|2.1 Team Member Roles and Responsibilities..........................................................................................................16|
|2.2 Work Plan........................................................................................................................................................... 17|
|**3.  PROJECT FUNCTIONALITIES............................................................................................................................... 19**|
|3.1 Technology Stack...............................................................................................................................19|
|3.2 Key Modules and Functionalities........................................................................................................................21|
|References.................................................................................................................................................... 24|
|**Appendix...................................................................................................................................................... 26**|





**PROJECT PROPOSAL** 

## **<mark>1. Introduction</mark>** 

### **1.1 Background Study** 

The problem which became the focus of this project is the urgent need to redirect tourist mobility away from carbon-heavy private transport and toward sustainable public transit networks. Globally, the domain of this project sits firmly within sustainable urban tourism and green mobility. In major international tourist hubs, municipal governments are actively battling the severe infrastructural strain caused by visitor mobility. When tourists navigate unfamiliar environments, they face significant "wayfinding anxiety" (Hoo, Waheeda, & Reesha, 2023). Due to a lack of familiarity with local public transport schedules, language barriers, and a general disorientation regarding pedestrian pathways, tourists systematically default to the path of least resistance: private taxis and e-hailing services. This behavioral default creates a compounding environmental crisis. Currently, urban tourism heavily relies on transportation, which contributes to approximately 75% of carbon dioxide emissions within the tourism sector globally (Fauziah Che Leh et al., 2023). 

This behavioral default creates a compounding environmental crisis. Currently, urban tourism heavily relies on transportation, which contributes to approximately 75% of carbon dioxide emissions within the tourism sector globally (Fauziah Che Leh et al., 2023). While tourists often express a desire to engage in eco-friendly practices, the physical friction of navigating a foreign city prevents them from utilizing green transit. Without targeted interventions that address the specific logistical and psychological barriers faced by foreign visitors, cities suffer from severe vehicular congestion that degrades both the environment and the local standard of living. 

Within Malaysia, specifically addressing this mobility and first-and-last-mile connectivity gap is critical in the lead-up to the Visit Malaysia 2026 (VM2026) campaign. With Tourism Malaysia officially targeting a massive influx of 43 million international visitors and rolling out a year-long calendar of more than 300 large-scale events and cultural festivals (VM2026, 2026), the urban transportation grids in the Klang Valley will experience unprecedented pressure. This massive wave of crowds makes green travel not just an option, but a strict necessity. This aligns directly with Tourism Malaysia’s official declaration that the VM2026 campaign underscores a national commitment to sustainable tourism development in line with the United Nations Sustainable Development Goals (UNSDGs) (VM2026, 2026). 



###### **PROJECT PROPOSAL** 

Despite the availability of the highly comprehensive Klang Valley Integrated Transit System, which includes the LRT, MRT, Monorail, and BRT networks, local data indicates a severe underutilization of these assets by non-local visitors. Tourists often avoid public transport due to a lack of clear, tourist-centric guidance and perceived inconvenience (Hoo, W. et al., 2023). Current municipal applications like MyRapid PULSE are designed strictly for daily local commuters who already know the geographical layout of the city; they do not cater to the discovery or navigation needs of a tourist exploring historical landmarks. 

The most significant deterrent preventing tourists from adopting public transit in Kuala Lumpur is the "first-and-last-mile" problem. Unlike daily commuters, tourists are heavily impacted by physical and environmental friction when traveling from a transit station to a final destination. Visitors are often unsure if a safe, continuous sidewalk exists, leading to fears of walking alongside busy, multi-lane highways. Furthermore, walking in Malaysia's tropical heat and humidity induces physical exhaustion. When tourists compare this physical exertion to the air-conditioned comfort of an e-hailing vehicle picking them up directly at their hotel lobby, the eco-friendly choice loses its appeal. Currently, the physical effort required to use public transit feels like a chore rather than an integrated, rewarding part of the travel experience. 

Without a smart, tourist-centric solution like CitiesWalk to mitigate these exact pain points, the millions of incoming VM2026 tourists will inevitably default to private cars and e-hailing services. This reliance will lead to severe street congestion in historical zones, heavily degrading the urban ecosystem. Furthermore, an influx of vehicular traffic actively diminishes the pedestrian walkability required to maintain a resilient, sustainable, and livable city for local residents (Salleh, 2023). Therefore, a system that not only maps safe pedestrian routes but also incentivizes the physical effort of walking through gamified health metrics is essential to shifting tourist behavior and achieving sustainable urban mobility. 



**PROJECT PROPOSAL** 

### **1.2 Project Description** 

The proposed project, "CitiesWalk" is a transit-oriented navigation and eco-fitness mobile application developed to support the Visit Malaysia 2026 (VM2026) campaign. Globally, tourism is responsible for roughly 8% of the world’s carbon emissions, with transportation serving as the primary driver of these greenhouse gases (Carbon Footprint of Tourism, 2024). Because private cars and e-hailing vehicles generate significantly higher CO₂ emissions per passenger mile than public buses and trains, popular urban tourism hubs experience severe traffic bottlenecks and environmental degradation. "CitiesWalk" directly addresses this issue by guiding visitors through Malaysia's cultural and historical landmarks exclusively via public transportation networks (such as the LRT and MRT) and pedestrian pathways. By integrating real-time carbon tracking with personal health metrics, the application incentivizes sustainable travel by demonstrating the dual benefits of reducing environmental impact and improving personal fitness. 

##### **Key modules of the project:** 

1. **User Management & Authentication Module:** Handles secure account access without requiring manual password storage. It leverages Supabase's built-in authentication system to let users log in instantly using their existing **Google (Gmail) or Facebook accounts** . It also utilizes native mobile biometric authentication (such as fingerprint or face recognition) for quick session unlocks, while providing a dedicated portal for users to manage and modify their personal profiles 

2. **Eco-Route Navigation Module:** Handles the map interface and location detection, routing users exclusively through public transit and safe walking paths. It features a predictive estimator to preview the projected CO₂ saved and calories burned before departure, along with a step-by-step guide for last-mile navigation. 

3. **Eco-Fitness & Carbon Analytics Module:** Tracks active travel using a background pedometer service. Upon completion, it calculates the exact calories burned and the precise amount of greenhouse gas emissions prevented, displaying the user's progress on a personal health and green dashboard. 

4. **Rewards & Leaderboard Module:** Gamifies the sustainable travel experience by converting the carbon saved and calories burned into a hybrid "Green & Fit" score. This module ranks users on a competitive health leaderboard and rewards them with digital badges and achievements to maintain long-term engagement. 



**PROJECT PROPOSAL** 

5. **Community Review & Rating Module:** Empowers tourists to make informed travel decisions through a community-driven feedback system. Users can read, write, and rate their experiences at various historical landmarks and tourist hotspots. The application automatically prioritizes and highlights high-rated destinations, helping undecided travelers easily discover the most enjoyable and worthwhile locations. 

##### **Targeted user** 

1. **Eco-Tourism Travelers:** Domestic and international tourists exploring Malaysia's urban historical zones during the VM2026 campaign who seek to combine cultural exploration with an active, sustainable lifestyle. 

2. **Health-Conscious Commuters:** Daily urban transit users and fitness enthusiasts who actively monitor their physical activity, caloric expenditure, and personal carbon footprint as part of a wellness-oriented lifestyle. 

3. **Sustainable Urban Navigators:** Travelers looking for a holistic mobile utility that bridges the gap between environmental responsibility, personal physical well-being, and efficient public transit navigation. 



**PROJECT PROPOSAL** 

### **1.3 UN SDG and Justification** 

- [ ] Goal 8: Decent Work and Economic Growth 

- [     /    ] Goal 11: Sustainable Cities and Communities 

- [ ] Goal 12: Responsible Consumption and Productions 

##### **Justification:** 

While the United Nations originally only linked a few specific sustainable goals to the tourism sector, current research emphasizes that tourism in Southeast Asia possesses an underused potential to drive progress across the entire spectrum of sustainable development goals (Trupp & Dolezal, 2020). However, the rapid expansion of tourism in the region has historically resulted in an ambiguous relationship with the environment, often leaving a patchy track record of negative community impacts and environmental conflicts (Trupp & Dolezal, 2020). 

The "CitiesWalk" application directly unlocks this underused potential by strictly aligning the influx of visitors from the Visit Malaysia 2026 campaign alongside daily commuters with the targets of SDG 11. By guiding tourists away from carbon-intensive private transport and shifting their foot traffic onto local public transit grids (LRT/MRT) and pedestrian networks, the project mitigates the negative impacts of urban tourism congestion. 

Crucially, CitiesWalk ensures the successful adoption of this sustainable infrastructure by utilizing personal health metrics as a behavioral catalyst. By tracking footsteps and translating green travel into tangible personal fitness achievements (calories burned), the app bridges the attitude-behavior gap that typically keeps tourists in private cars. This incentive structure ensures that Malaysian heritage cities can host high volumes of visitors without degrading local urban ecosystems, effectively preserving urban walkability and maintaining a balanced, low-carbon community. 



**PROJECT PROPOSAL** 

### **1.4 Existing Work** 

An analysis of the current market reveals that existing mobile solutions targeting urban mobility are broadly divided into two major categories. While these applications are highly functional in their respective domains, they present significant operational limitations when evaluated against the unique requirements of sustainable urban tourism: 

##### 1. Mass-Market Navigation Tools (e.g., Google Maps, Waze) 

These are general-purpose navigation engines used globally for turn-by-turn routing and real-time traffic updates. Their core algorithms calculate travel paths based almost entirely on the absolute fastest estimated time of arrival (ETA). This mathematical layout inherently biases their system recommendations toward private motor vehicles and e-hailing options over eco-friendly transit, worsening city center traffic congestion. 

##### 2. Local Municipal Transit Schedulers (e.g., MyRapid PULSE, Moovit) 

These apps function as local utility trackers that provide transit schedules, route networks, and arrival times for rail and bus grids. These solutions are designed strictly as utility interfaces for local, daily commuters. They entirely lack tourist-centric discovery routes, historical landmark guidance, localized cultural insights, and motivational engagement. 

##### **Critical Analysis and Market Gaps** 

The structural failure of current applications to inspire eco-friendly travel stems from a lack of emotional and experiential engagement. According to recent empirical studies, experiential enjoyment and personal, tangible rewards are the single strongest predictors of a tourist's willingness to voluntarily utilize public transit networks for leisure activities (Kamarudin, N., Sinniah, G. K., Jaafar, S. M. R. S., & Yusof, J. N., 2025). 

Because current market alternatives treat public transportation as a dry, functional chore rather than a rewarding lifestyle achievement, they fail to bridge the critical "eco-attitude-behavior gap" among travelers (Ahmad, S. Y., Ibrahim, S. H., & Hama, S., 2025). Travelers often voice strong verbal support for environmental preservation but default back to private vehicles due to the perceived complexity or uninspiring nature of traditional transit apps. This leaves a clear gap for a solution that combines dedicated transit routing with active health incentives. 



**PROJECT PROPOSAL** 

### **1.4.1 Competitor Analysis** 

To ensure the viability of the "CitiesWalk" application, a comparative analysis was conducted against three distinct types of existing mobile applications in the current market consisting of a mass-market navigation app (Waze), a dedicated health and fitness tracker (Strava), and the official national tourism application (Malaysia Truly Asia). As shown in **Table 1.4** , this comparative assessment highlights the functional gaps in the current market that CitiesWalk aims to fill by integrating transit-exclusive navigation, personal health metrics, and gamified environmental rewards into a single platform. 

**Table 1.4: Functional Gap Analysis of Existing Market Solutions vs. CitiesWalk** 

|**Feature**|**CitiesWalk**<br>**(Yours)**|**Waze**|**Strava**|**Malaysia**<br>**Truly Asia**|
|---|---|---|---|---|
|**Point-to-Point**<br>**Routing**|✅|✅|❌|✅|
|**Public**<br>**Transit**<br>**&**<br>**Walk Only**|✅|❌|❌|❌|
|**Calorie & Pedometer**<br>**Tracking**|✅|❌|✅|❌|
|**Carbon**<br>**Footprint**<br>**Calculator**|✅|❌|❌|❌|
|**Gamified**<br>**Eco-Leaderboard**|✅|❌|❌|❌|





**PROJECT PROPOSAL** 

#### **Analysis of Market Gaps** 

1. **Waze (Navigation Focus):** Waze is a highly sophisticated platform utilizing crowdsourced data from over 100 million active monthly users to help travelers avoid traffic gridlocks, find parking spaces, and locate fuel stations (Bradford, 2023). It even attempts to offer eco-conscious features through a community "Carpool" matching system designed to save fuel (Bradford, 2023). 

**The Core Gap:** Despite these features, Waze’s entire infrastructure is built to optimize **motorized vehicular travel** (Bradford, 2023). Its features such as parking tracking, gas station locators, and speedometer alerts are useless to an eco-tourist who wants to explore historic urban zones strictly on foot or via electric rail lines like the LRT/MRT. Waze entirely lacks native pedometer synchronization, calorie tracking, or a rewards mechanism tied to walking, meaning it cannot bridge the attitude-behavior gap for pedestrians. 

2. **Strava (Fitness Focus):** Strava functions as a comprehensive training diary and performance tracker, holding a massive market share as the world's largest fitness community. It offers highly advanced features such as AI-powered "Athlete Intelligence" to summarize workout data (like heart rate, elevation, and effort), an addictive competitive "Segments" system for local runners to challenge one another, and premium route-planning maps built using data from millions of athletic activities to identify popular running paths. 

**The Core Gap:** Despite its massive athletic ecosystem, Strava is fundamentally designed for structured athletic training and sports performance. As a result, its features are entirely misaligned with the needs of casual urban tourists navigating a new city during the Visit Malaysia campaign. Strava's premium routing engine relies on running/cycling paths tested by local athletes rather than mapping out public transportation networks (such as integrating LRT/MRT transfers or multi-modal transit timetables). Furthermore, its complex AI analytics focus heavily on physical strain and athletic conditioning, which is overwhelming for everyday tourists who simply want a straightforward overview of their basic steps, localized destination ratings, and the environmental impact (CO₂) of choosing public transit over a car. 

3. **Malaysia Truly Asia (Official Tourism Focus):** The official Malaysia Truly Asia application serves as a comprehensive digital companion designed to promote the country's multi-cultural identity, renowned local culinary scenes, and rich historical heritage zones. It acts as a digital storefront to showcase iconic urban destinations, tropical nature spots, and budget-friendly travel opportunities. 



**PROJECT PROPOSAL** 

**The Core Gap:** A major disconnect exists between what the tourism market promotes and what the official app digitally delivers. While contemporary travel literature emphasizes that Kuala Lumpur features a highly _"convenient and speedy public transport"_ rail network (Rapid Transit, monorail, and commuter rail) intertwined with highly walkable districts like Chinatown and Little India, the official app fails to provide a real-time, point-to-point transit navigation engine to help users actually utilize this grid (tourHQ, 2026). 

Furthermore, because experiencing the city's authentic history and street food requires tourists to physically _"walk down the street,"_ the app lacks any pedestrian health metrics (such as step counts or calorie tracking) or gamified rewards to actively motivate walking (tourHQ, 2026). Instead of providing digital self-guided tools, mainstream travel platforms heavily rely on advising tourists to hire traditional, private _"local tour guides"_ to navigate these urban spaces (tourHQ, 2026). This highlights a critical market gap for CitiesWalk, which digitizes the local guiding experience by actively routing budget-conscious travelers through cultural hotspots using only public rail and pedestrian paths. 

#### **Conclusion** 

Currently, an eco-conscious tourist visiting Malaysia must download and toggle between three separate applications just to navigate a street, track their fitness, and view restaurant or location ratings. "CitiesWalk" serves as a holistic, all-in-one solution that eliminates this friction by merging transit-exclusive routing, personal health tracking, and gamified environmental rewards into a single platform. 



**PROJECT PROPOSAL** 

### **1.5 Project Significance** 

The prospective implementation of the "CitiesWalk" application holds paramount strategic significance as it directly intersects with the national agenda of the Visit Malaysia 2026 (VM2026) campaign and the global mandates outlined in the United Nations Sustainable Development Goal 11: Sustainable Cities and Communities. With millions of international and domestic tourists projected to descend upon Malaysia's urban and historical centers, the traditional transport infrastructure faces imminent strain. "CitiesWalk" serves as a critical technological intervention designed to transition tourist mobility away from private, carbon-intensive transport modalities and toward eco-friendly, public transit frameworks, thereby delivering substantial environmental, personal health, and infrastructural value to society. 

This project will comprehensively contribute to the following three dimensions: 

##### **a. Mitigating Urban Carbon Footprints and Traffic Gridlocks during VM2026** 

The influx of global visitors during peak tourism years historically correlates with an exponential surge in the utilization of private ride-hailing services and rental vehicles, which severely exacerbates urban traffic gridlocks and accelerates localized greenhouse gas emissions. "CitiesWalk" directly addresses this environmental threat by restricting its primary routing algorithms exclusively to public transit grids—such as the LRT, MRT, and BRT systems—coupled with designated pedestrian pathways. By systematically diverting thousands of tourist commuter trips away from roads and onto electrified rail networks, the application actively lowers transport-related urban carbon emissions, preserves air quality, and prevents catastrophic gridlocks in high-density heritage tourism zones, establishing a blueprint for low-carbon event hosting (Carbon Footprint of Tourism, 2024). 

##### **b. Bridging the Eco-Attitude-Behavior Gap through Personal Health Incentives** 

A persistent challenge in sustainable tourism is the "attitude-behavior gap," where consumers express high theoretical awareness of environmental preservation but fail to act on it due to the perceived inconvenience, complexity, or mundane nature of public transportation. "CitiesWalk" strategically overcomes this psychological barrier by translating abstract environmental goals into tangible, personal benefits. By integrating a Background Pedometer and an Eco & Health Impact Tracker, the application quantifies both carbon emissions prevented and calories burned during a user's journey. This dual-metric approach injects personal value and fitness-driven "enjoyment" into green travel. Empirical evidence demonstrates that leveraging such intrinsic personal motivations is a powerful predictor of a tourist's willingness to voluntarily adopt public transit, effectively shifting consumer behavior from passive environmental awareness to active sustainable participation (Kamarudin et al., 2025). 



**PROJECT PROPOSAL** 

##### **c. Enhancing First-and-Last-Mile Transit Resilience and Urban Walkability** 

The structural failure of many urban centers to sustain public transit ridership stems from the "first-and-last-mile" connectivity gap, which induces anxiety in non-local visitors regarding navigation safety, transit scheduling, and sidewalk accessibility. "CitiesWalk" systematically resolves these logistical vulnerabilities by providing optimized, highly visible pedestrian mapping and real-time transit synchronization tailored specifically to encourage active mobility for tourists. Elevating the walkability of transit corridors not only maximizes the utilization and ROI of existing municipal transit networks, but it also fosters a resilient urban ecosystem. Ultimately, this ensures that historic Malaysian cities can seamlessly accommodate immense tourist volumes during VM2026 without degrading the surrounding urban ecosystem, compromising pedestrian safety, or diminishing the daily standard of living for local resident communities (Salleh, 2023). 



**PROJECT PROPOSAL** 

###### **1.3 Background Study** 

The problem which became the focus of this project is the urgent need to redirect tourist mobility away from carbon-heavy private transport and toward sustainable public transit networks, specifically addressing the first-and-last-mile connectivity gap during the Visit Malaysia 2026 (VM2026) campaign. The domain of this project sits firmly within sustainable urban tourism and green mobility. With Tourism Malaysia officially targeting a massive influx of 43 million international visitors and rolling out a year-long calendar of more than 300 large-scale events and cultural festivals (VM2026, 2026), urban transportation grids will experience unprecedented pressure. This massive wave of crowds makes green travel a strict necessity, aligning directly with Tourism Malaysia’s official declaration that the VM2026 campaign underscores a national commitment to sustainable tourism development in line with the United Nations Sustainable Development Goals (UNSDGs) (VM2026, 2026). Currently, urban tourism heavily relies on transportation, which contributes to approximately 75% of carbon dioxide emissions within the tourism sector (Fauziah Che Leh, Isa, Mohd Hairy Ibrahim, Ibrahim, M., Mohd, & Johan Afendi Ibrahim, 2023). In Kuala Lumpur, despite the availability of the comprehensive Klang Valley Integrated Transit System, non-local visitors often avoid public transport due to a lack of clear, tourist-centric guidance and perceived inconvenience (Hoo, W., Waheeda, A., & Reesha, A., 2023). Without a smart solution like CitiesWalk, these millions of incoming tourists will default to private cars and e-hailing services, leading to severe street congestion, degrading the urban ecosystem, and actively diminishing the pedestrian walkability required to maintain a resilient, sustainable city (Salleh, 2023). 

The proposed  "CitiesWalk," application provides immense value by filling this critical gap in the market. By actively restricting route calculations to public transit and pedestrian pathways, it directly answers the call for actionable low-carbon urban tourism policies (Azhari et al., 2023). From a technical standpoint, the project is highly feasible. It utilizes a standard three-layer architecture (GUI, Business Logic, Data Processing) and leverages standard mapping APIs and native device sensors (GPS and pedometers), remaining fully compliant with the assignment constraints by avoiding complex e-commerce or 3D AR systems. 

Furthermore, the integration of a dual-metric tracking system combining a Carbon Footprint Calculator with a Background Calorie Tracker injects the missing psychological incentive into the user experience. By translating abstract environmental responsibility into tangible, personal health achievements (calories burned), CitiesWalk transforms a basic transit ride into a rewarding lifestyle choice. This directly bridges the attitude-behavior gap, ensuring the solution is both technically 





**PROJECT PROPOSAL** 

## **2. TEAM STRUCTURE & WORK PLAN** 

### **2.1 Team Member Roles and Responsibilities** 

To ensure the successful execution and delivery of the CitiesWalk project, the team has adopted a structured, role-based approach as detailed in Table 2.1. This distribution aligns with standard software engineering practices and our official group contract, ensuring clear accountability across all phases of the system development life cycle (SDLC). Each member has been assigned a specific leadership role ranging from requirement gathering and system design to core development and quality assurance to guarantee that all technical and managerial deliverables are met within the project timeline. 

Table 2.1: Formal Distribution of Team Roles and Responsibilities 

|**ROLE AND RESPONSIBILITIES**|**TEAM MEMBER**|
|---|---|
|Project Manager|CHUA THIAM POH|
|Requirement Lead|KOH HUAI YU|
|Design Lead|LAI YU WAI|
|Coding/Development|ENG ZHEN XIN|
|Testing Lead|TAN YAN ZUN|





**PROJECT PROPOSAL** 

### **2.2 Work Plan** 

The development of the CitiesWalk application follows a structured, 14-week timeline that incorporates iterative development practices alongside standard system development life cycle (SDLC) phases. As shown in Table 2.2, the schedule is strategically divided into key milestones, beginning with foundational research and requirement gathering, progressing through two core development sprints, and concluding with rigorous validation and final deployment. This organized schedule ensures continuous progress monitoring and the timely completion of all technical and administrative deliverables. 

Table 2.2: Project Work Plan and Timeline 

|**PROJECT ACTIVITIES**||**TIME / DURATION**|
|---|---|---|
|Project Kickoff: Idea brainstorming,|||
|UN SDG justification, background|Weeks 1 - 2||
|study research, and Proposal write-up|||
|Proposal Submission: Proposal<br>presentation and high-level|Week 3||
|requirement gathering|||
|Requirement Specification: Construct|||
|Use Case diagrams, descriptions, and|Weeks 4 - 10||
|finalize requirement documentation|||
|Design Specification: Software<br>architecture, component interfaces,|Weeks 4 - 10||
|GUI mockups, and Progress Pitch 1|||
|Core Development (Sprint 1):|||
|Framework setup, database storage|Weeks 4 - 7||
|integration, and UI development|||
|Core Development (Sprint 2):|||
|Implement logical/business<br>processing layers (Route mapping,|Weeks 7 - 10||
|Carbon logic, Rewards)|||
|Testing & Validation: Validate|||
|functionalities against requirements,|Week 10 - 11||
|bug tracking, Progress Pitch 2|||
|Project Refinement: Final bug fixes,|||
|UI polish, and presentation pitch<br>preparation|Week 12||





**<u>PROJECT PROPOSAL</u>** 

Final Delivery: Official project presentation, demo, and Final Week 13 - 14 Assessment Document submission 

##### **Gantt Chart** 

|**Project Activities**<br>**Week 1**<br>**Week 2**<br>**Week 3**<br>**Project Kickoff:**<br>**Idea**<br>**brainstorming, UN**<br>**SDG justification,**<br>**background study**<br>**research, and**<br>**Proposal write-up**|**Week 4**<br>**Week 5**|**Week 6**<br>**Wee**|**k 7**<br>**Week 8**|**Week 9**<br>**Week 10**<br>**Week 11**<br>**Week 12**<br>**Week 13**<br>**Week 14**|
|---|---|---|---|---|
|**Proposal**<br>**Submission:**<br>**Proposal**<br>**presentation and**<br>**high-level**<br>**requirement**<br>**gathering**|||||
|**Requirement**<br>**Specification:**<br>**Construct Use**<br>**Case diagrams,**<br>**descriptions, and**<br>**finalize**<br>**requirement**<br>**documentation**|||||
|**Design**<br>**Specification:**<br>**Software**<br>**architecture,**<br>**component**<br>**interfaces, GUI**<br>**mockups, and**<br>**Progress Pitch 1**|||||
|**Core Development**<br>**(Sprint 1):**<br>**Framework setup,**<br>**database storage**<br>**integration, and**<br>**UI development**|||||
|**Core Development**<br>**(Sprint 2):**<br>**Implement**<br>**logical/business**<br>**processing layers**<br>**(Route mapping,**<br>**Carbon logic,**<br>**Rewards)**|||||
|**Testing &**<br>**Validation:**<br>**Validate**<br>**functionalities**<br>**against**<br>**requirements, bug**<br>**tracking, Progress**<br>**Pitch 2**|||||
|**Project**<br>**Refinement: Final**<br>**bug fixes, UI**<br>**polish, and**<br>**presentation pitch**<br>**preparation**|||||
|**Final Delivery:**<br>**Official project**<br>**presentation,**<br>**demo, and Final**<br>**Assessment**<br>**Document**<br>**submission**|||||





**PROJECT PROPOSAL** 

## **<mark>3. PROJECT FUNCTIONALITIES</mark>** 

### **3.1 Technology Stack** 

The "CitiesWalk" project is designed as a mobile application to directly support its primary target audience of on-the-go tourists navigating outdoor historical sites and public transit networks during the Visit Malaysia 2026 (VM2026) campaign. This mobile-centric approach is strictly required to leverage native device capabilities such as real-time GPS tracking for pedestrian routing, push notifications for transit alerts, and built-in motion sensors for continuous fitness and step tracking. Traditional web-based or standalone desktop systems cannot provide the necessary portability, real-time location-based engagement, or direct hardware access required to solve the "first-and-last-mile" navigation problem while simultaneously monitoring a user's physical activity to calculate caloric expenditure for competitive leaderboard rankings. 

Technology to be Used in the Project & Justifications: 

To ensure high performance and feasibility within the project timeframe, the application will adopt a standard three-layer architecture utilizing the following modern technology stack: 

##### 1. Frontend Development (GUI Layer): Flutter (Dart) 

   - Flutter is a highly efficient UI toolkit that allows the development of natively compiled applications for both iOS and Android from a single codebase. Since international tourists use a diverse range of smartphone operating systems, cross-platform compatibility is crucial. Flutter also provides rich, customizable widgets that are perfect for building the Eco-Route Planner, the fitness tracking dashboard, and a dynamic, real-time "Green & Fit" leaderboard. 

2. Backend & Database (Business Logic & Data Processing): Supabase (PostgreSQL) 

   - Supabase provides an open-source Backend-as-a-Service (BaaS) built on top of a robust PostgreSQL relational database. This is highly beneficial for "CitiesWalk" as it ensures strict data integrity when managing complex relational structures, such as linking user profiles to historical carbon transit logs and daily step-count records. Crucially, PostgreSQL's advanced querying capabilities allow the system to instantly sort and retrieve user data to display the real-time leaderboard. Furthermore, Supabase offers instant built-in authentication and real-time database listeners via its official Flutter SDK, minimizing backend boilerplate development. 



**PROJECT PROPOSAL** 

3. Mapping and Location Services: Google Maps Platform APIs 

   - To accurately calculate pedestrian pathways and restrict routing strictly to public transit grids, the application will integrate Google Maps APIs (such as the Directions API and Places API) alongside native device GPS. This provides reliable, up-to-date spatial data and localized transit schedules required to alleviate tourists' travel anxiety without requiring the team to build a proprietary mapping engine. 

5. Fitness & Background Tracking: Native Health APIs 

   - To implement the background pedometer functionalities, the application will utilize Flutter plugins (such as the health package) to interact directly with the device's native health data ecosystems, Health Connect for Android and HealthKit for iOS. This allows the app to accurately track steps and walking distances even when the app is in the background. The system will then use conversion algorithms to calculate the estimated calories burned. This reliable hardware data feeds directly into the leaderboard system, translating physical effort into gamified eco-achievements. 



**PROJECT PROPOSAL** 

### **3.2 Key Modules and Functionalities** 

|**MODULE**|**FUNCTIONALITIES**|
|---|---|
|1. Eco-Route Navigation Module|1. **Current Location Detection (GPS)**:Automatically<br>finds where the user is standing using the phone’s<br>built-in GPS so they can start their trip from the exact<br>right spot.<br>2. **Place Search & Discovery:**An easy search bar that<br>helps tourists search for tourist sites, local foods, or<br>historical landmarks (like Batu Caves).<br>3.**Train & Walk Only Routing Engine:**Calculates a<br>route that_only_uses public transport (LRT, MRT,<br>Monorail) and safe walking paths. It completely blocks<br>out cars and taxis.<br>4.**Predictive Route Estimator (Pre-Departure)**Before<br>the user clicks "Start", this feature guesses and<br>previews the trip details: how long it will take, which<br>platform to go to, how much carbon (CO₂) they will<br>save, and how many calories they are expected to<br>burn.<br>5.**Step-by-Step Walking Guide:**Shows a clear, simple<br>timeline of the trip so the tourist doesn’t get lost when<br>exiting a train station (solving the "last-mile"<br>navigation fear).|
|2. Eco-Fitness & Carbon Analytics<br>Module|1.**Background Pedometer Tracker:**A background<br>service that reads the phone's built-in sensors to count<br>the user’s steps automatically, even when the phone is<br>locked or the app is closed.<br>2. **Calorie Burned Calculator:**Takes the steps and<br>distance walked during the trip and converts them into<br>a score showing exactly how many calories the user<br>burned.<br>3.**Carbon Savings Tracker:**Calculates how many<br>kilometers the user traveled on the train/foot instead of<br>a car, and shows the exact amount of greenhouse gas<br>(CO₂) they saved.|





**<u>PROJECT PROPOSAL</u>** 

||4.**Personal Fitness & Green Dashboard:**A clean<br>visual page full of simple charts showing the user's<br>daily and weekly walking history and environmental<br>achievements.|
|---|---|
|3. Rewards & Leaderboard Module|1.**Hybrid "Green & Fit" Points Engine:**Combines the<br>calories burned and the carbon saved from a trip,<br>turning them into points (currency) for the user.<br>2.**Health Leaderboard:**A competitive scoreboard that<br>ranks users based on who has burned the most calories<br>and walked the furthest, motivating them to stay<br>healthy.<br>3.**Digital Badges & Achievements Locker:**Pop-up<br>rewards that unlock digital badges (like_"Kuala_<br>_Lumpur Explorer Badge"_) when a user completes a<br>walk or reaches a health milestone.|
|4.User Management & Authentication<br>Module|1.**Social OAuth Sign-In (Google & Facebook):**Allows<br>tourists and commuters to instantly log in using their<br>existing Google (Gmail) or Facebook accounts via<br>Supabase's built-in external providers. This completely<br>eliminates manual form registration. Upon a user's first<br>login, Supabase automatically generates a secure<br>unique identifier (UUID) and saves their basic profile<br>(such as email and name) into its built-in PostgreSQL<br>auth.users table, meaning the system never has to store<br>or manage sensitive passwords.<br>2.**Biometric Session Re-Authentication:**Integrates<br>with the mobile phone's native hardware sensors<br>(Touch ID / Face ID / Android Fingerprint) to securely<br>re-verify the user's identity. This allows the app to<br>refresh the user's active Supabase access token without<br>making them re-click the Google or Facebook login<br>buttons every time they open the app.<br>3.**Federated Profile Syncing & Customization:**Uses<br>the secure UUID automatically generated by the|





||**PROJECT PROPOSAL**<br>Supabase auth.users table to link the user's social<br>identity to their active trip data. This ensures that every<br>calorie burned, and every kilogram of carbon saved, is<br>accurately attached to their personal account and<br>correctly<br>displayed<br>on<br>the<br>real-time<br>public<br>leaderboard. Users also have access to a settings page<br>to customize their app display name.|
|---|---|
|5.Community Review & Rating Module|**1. 5-Star Rating & Text Feedback:**Allows users who<br>have visited a specific location to rate the destination<br>out of 5 stars and leave a written review detailing their<br>personal experience, such as how fun the place was,<br>crowd levels, or transit convenience.<br>**2. Sorting & Prioritization:**The system automatically<br>calculates the average score for each destination and<br>prioritizes high-rated locations at the top of the "Place<br>Search & Discovery" page, ensuring users see the most<br>highly recommended spots first.<br>**3. Review Browsing & Filtering:**Before confirming a<br>route, undecided tourists can scroll through past<br>reviews from other travelers. They can filter reviews<br>by "Highest Rated" or "Most Recent" to get an<br>accurate, up-to-date understanding of the location's<br>current conditions.|





**PROJECT PROPOSAL** 

## **References** 

Ahmad, S. Y., Ibrahim, S. H., & Hama, S. (2025). Attitude, Subjective Norms and The Adoption of Green Transportation Modes among Generation Z’s Willingness to Travel to Kuala Lumpur. _journals.iium.edu.my_ . https://doi.org/10.31436/jocth.v1i1.10 

- Bradford, A. (2023, January 6). 12 clever waze features you’re probably not using. _Reader’s Digest_ . <u>https://www.rd.com/list/waze-features/</u> 

_Carbon footprint of tourism_ . (2024) (n.d.). Sustainable Travel International. <u>https://sustainabletravel.org/issues/carbon-footprint-tourism/</u> 

- Fauziah Che Leh, Isa, Mohd Hairy Ibrahim, Ibrahim, M., Mohd, & Johan Afendi Ibrahim. (2023). A Literature Review of Low-Carbon Urban Tourism Indicators and Policy. _Pertanika Journal of Social Science & Humanities_ , _31_ (2), 655–681. 

<u>https://doi.org/10.47836/pjssh.31.2.10</u> 

- Hoo, W., Waheeda, A., & Reesha, A. (2023). Factors influencing the passenger satisfaction at public transport in Kuala Lumpur, Malaysia. _Journal of Project Management Practice_ , _3_ (1), 77–94. <u>https://doi.org/10.22452/jpmp.vol3no1.4</u> 

- Kamarudin, N., Sinniah, G. K., Jaafar, S. M. R. S., & Yusof, J. N. (2025). EXTRINSIC AND INTRINSIC MOTIVATION OF URBAN TOURISTS TO TRAVEL WITH PUBLIC TRANSPORT FOR LEISURE: ANALYSIS OF TRIPADVISOR REVIEWS. _PLANNING MALAYSIA_ , _23_ . <u>https://doi.org/10.21837/pm.v23i35.1679</u> 

- Salleh, A. (2023). _We need walkability for a resilient city_ . PNB Research Institute. <u>https://pnbri.com.my/sites/default/files/2025-07/PNBRi%20Views%2002%20-%20Walkability%20f or%20a%20resilient%20city.pdf</u> 

- Team, S. R. (2026, June 29). Strava for Runners: A complete guide to features, benefits and the subscription. 

   - _The Sapphire Running Zone_ . 

<u>https://www.sapphirerunningzone.com/post/strava-getting-to-know-its-features</u> 



**PROJECT PROPOSAL** 

tourHQ. (2026, April 7). The Top Five Reasons Why Malaysia is “Truly Asia.” _TourHQ Limited_ . 

<u>https://www.tourhq.com/article/the-top-five-reasons-why-malaysia-is-truly-asia</u> 

Trupp, A., & Dolezal, C. (2020). Tourism and the sustainable development goals in Southeast Asia. _Sunway Institutional Repository (Sunway University)_ . https://doi.org/10.14764/10.aseas-0026 

Wu, Z., & Geng, L. (2020). Traveling in haze: How air pollution inhibits tourists’ pro-environmental 

behavioral intentions. _Science of the Total Environment_ , _707_ , 135569. <u>https://doi.org/10.1016/j.scitotenv.2019.135569</u> 

_VM2026 (2026). VM2026 OFFICIALLY BEGINS: MALAYSIA ROLLS OUT a WARM WELCOME NATIONWIDE_ . (n.d.). 

<u>https://www.tourism.gov.my/media/view/vm2026-officially-begins-malaysia-rolls-out-a-warm-welco me-nationwide</u> 



**PROJECT PROPOSAL** 

## **Appendix** 



**PROJECT PROPOSAL** 

. 

So little template Background study 1.1 Focus on problem Elaborate more on problem (tourist facing and other country), how other country solve the problem, do one and half page 

1.4 existing work 1.4.1Comparison studies inside create table product 1,2,3 

1.2 project description 1.3 SDG 1.5 Project significant Table must have caption. Give intro refer table 2.1 for details Table on top figure on bottom for table don't care Cannot start type of... Use paragraph Appendix data sources: url, questionnaire List of places to recommend: wikivoyage, scraping from Wikipedia General FR no need More than 30 above functional requirements 

Include user module, biometric, login, edit profile, mobile app - MySQL, go step by step cover everything 

Pick two non fr for overall specific for this non FR how you plan to test, try to consult with software testing mention mobile app 

Column for stories point evaluate based on complexity. What are the column needed for product backllg 

Must be as more as fr 



**PROJECT PROPOSAL** 

|**Prio**<br>**rity**|**Module**|**User Story**|
|---|---|---|
|**High**|Navigati<br>on|**As a**tourist,**I want to**input my<br>destination,**so that**I can see a<br>step-by-step route using public<br>transit and safe pedestrian paths.|
|**High**|Navigati<br>on|**As a**pedestrian,**I want to**be<br>routed only on safe sidewalks<br>(avoiding highways),**so that**I am<br>not put in physical danger while<br>walking.|
|**High**|Fitness|**As a**user,**I want the**app to<br>automatically track my steps in the<br>background,**so that**I don't have to<br>manually start a workout every time<br>I walk to a station.|
|**High**|Fitness|**As a**health-conscious traveler,**I**<br>**want to**see my exact calories<br>burned after a walk,**so that**my<br>physical effort feels validated and<br>rewarded.|
|**Medi**<br>**um**|Reward<br>s|**As a**tourist,**I want to**earn Green<br>Points based on the calories I burn,<br>**so that**I have a tangible incentive<br>to choose walking over e-hailing.|
|**Medi**<br>**um**|Fitness|**As an**eco-traveler,**I want to**view<br>a dashboard showing my total CO₂<br>saved compared to taking a car,**so**|





**<u>PROJECT PROPOSAL</u>** 

|||**that**I can track my environmental<br>impact.|
|---|---|---|
|**Medi**<br>**um**|Navigati<br>on|**As a**tourist,**I want to**see<br>estimated CO₂savings before I<br>confirm my route,**so that**I can<br>make an informed, eco-friendly<br>transport choice.|
|**Medi**<br>**um**|Reward<br>s|**As a**competitive user,**I want to**<br>see my rank on a public "KL<br>Explorer" leaderboard,**so that**I am<br>motivated to walk more to beat<br>other tourists.|
|**Low**|Navigati<br>on|**As a**user,**I want to**report a<br>broken sidewalk or hazard on the<br>map,**so that**the system can<br>reroute other pedestrians safely.|
|**Low**|Reward<br>s|**As a**new user,**I want to**unlock<br>digital<br>badges<br>(e.g.,<br>"5km<br>Milestone"),**so that**I get instant<br>gratification for building sustainable<br>habits.|
|**Low**|Fitness|**As a**tourist,**I want to**view my<br>historical weekly walking data,**so**<br>**that**I can see how my active<br>mobility has improved during my<br>trip.|
|**High**|User<br>Module|**As an**on-the-go tourist,**I want to**<br>log in instantly using my**Google or**<br>**Facebook account**, so that I don't|





**<u>PROJECT PROPOSAL</u>** 

|||have to spend time filling out long<br>registration forms.|
|---|---|---|
|**High**|User<br>Module|**As a**returning user,**I want to**use<br>my**fingerprint or Face ID**to<br>unlock my session,**so that**the app<br>instantly<br>refreshes<br>my<br>token<br>without making me re-authenticate<br>through Google/Facebook.|
|**Medi**<br>**um**|User<br>Module|**As a**traveler,**I want**the app to<br>automatically sync my profile name<br>from my social login,**so that**my<br>account<br>identity<br>is<br>set<br>up<br>effortlessly on day one.|
|**High**|Review<br>&<br>Rating|**As an**undecided tourist,**I want to**<br>view the average star rating of a<br>destination,**so that**I can quickly<br>decide if the place is popular and<br>worth visiting.|
|**Medi**<br>**um**|Review<br>&<br>Rating|**As a**traveler,**I want to**read<br>detailed<br>written<br>reviews<br>from<br>previous visitors,**so that**I can<br>learn about the actual experience<br>and conditions of the place before<br>going.|
|**Medi**<br>**um**|Review<br>&<br>Rating|**As a**user who just completed a<br>trip,**I want to**leave a rating and<br>review for the location,**so that**I<br>can share my experience and help<br>future tourists make good choices.|





