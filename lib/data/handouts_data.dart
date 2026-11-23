class HandoutItem {
  final int number;
  final String title;
  final String? content;
  final List<String>? pages;
  const HandoutItem(this.number, this.title, {this.content, this.pages});
}

class SessionHandout {
  final String sessionName;
  final List<HandoutItem> items;
  const SessionHandout(this.sessionName, this.items);
}

class ModuleHandout {
  final int moduleNumber;
  final String moduleName;
  final List<SessionHandout> sessions;
  const ModuleHandout(this.moduleNumber, this.moduleName, this.sessions);
}

const List<ModuleHandout> foodHandouts = [
  ModuleHandout(1, 'Understanding Prediabetes & Nutrition Foundations', [
    SessionHandout('Session 1: Welcome to Your Diabetes Prevention Journey', [
      HandoutItem(1, 'Understanding Prediabetes', content: "Welcome to your Diabetes Prevention Journey! This program is designed to help you take small, meaningful steps toward a healthier life. Over the coming weeks, you'll learn about nutrition, movement, and habits that can make a real difference — one session at a time. Let's get started!\n\nPrediabetes means that blood sugar is high but not yet high enough to be type 2 diabetes."),
      HandoutItem(2, 'Understanding Type 2 Diabetes', pages: [
        "What is type 2 diabetes?\nType 2 diabetes is a disease caused by having too much sugar in our blood. The sugar in the blood is called glucose, pronounced GLUE-kose.\n\nHow do we get glucose?\nWe get glucose from the food we eat. Our body breaks down all the sugar and starch we eat into glucose. Glucose is the basic fuel for the cells in our body.\n\nHow do we get too much glucose in our blood?\nNormally our bodies use a hormone called insulin to carry the glucose in our blood to the other cells in our body. The amount of glucose in our blood can get too high for two reasons: 1) our body does not have enough insulin, or 2) our body does not use insulin properly.",
        "What happens when the glucose in our blood gets too high?\nThe glucose builds up in the blood instead of going into the cells, and we get diabetes. Diabetes can damage many parts of the body, including the heart, eyes, kidneys, and nerves.\n\nHow can we stop ourselves from getting type 2 diabetes?\nParticipating in a lifestyle intervention to lose some weight and become more active can prevent diabetes."
      ]),
      HandoutItem(3, 'Introduction to NDPP', pages: [
        "Welcome / Program goals: You are here because you want to reduce your risk for type 2 diabetes. We will work together toward two goals — losing weight and being more active. You'll lose 7% of your weight through healthy eating and 150 minutes of brisk physical activity each week.\n\nReaching goals together: We will meet for one year — once a week for the first 16 weeks, then once a month. Reaching your goal weight may prevent you from getting type 2 diabetes or heart disease. You will look and feel better, and your health will improve.",
        "What is the Diabetes Prevention Program (DPP)? The original DPP was a research study funded by the National Institutes of Health (NIH) and supported by the Centers for Disease Control and Prevention (CDC). The results showed that making certain lifestyle changes and continuing them over time can prevent type 2 diabetes in people who are at risk.",
        "Who took part in the research study? More than 3,000 adults took part, from 27 locations around the United States. Everyone in the study had prediabetes. Nearly half were African Americans, Hispanics, American Indians, Asians, or Pacific Islanders — groups at high risk for type 2 diabetes. 2 out of 10 were 60 years old or older — people older than 60 are at higher risk than younger people. The average starting weight of people in the study was 207 pounds.",
        "How did the researchers do the study? Each person was randomly assigned to one of three treatment groups: Lifestyle change (1,000 people focused on losing weight and being more active, no medication); Medication (1,000 people given metformin, a medication used to treat diabetes, with no focus on weight or activity); No treatment (1,000 people, no medication, not asked to change lifestyle).",
        "What happened? The groups were studied for about 3 years. Lifestyle change cut risk for type 2 diabetes by 58% (71% for people older than 60). Medication cut risk by 31%. No treatment showed no change in risk. The research study and many later studies showed that lifestyle changes are best at preventing type 2 diabetes, which is why programs like this one have been set up throughout the United States and the world.",
        "Our goal: This program is based on the DPP study and many studies conducted since. It will help you learn the facts about healthy eating and being active, learn what makes it hard to eat healthy and be active, learn how to change your habits to healthier ones, and maintain the long-term support needed to stick with the changes.",
        "Program organization: This program has 16 sessions conducted over the next 16 to 20 weeks, in three parts. Getting Started (Sessions 1–6) covers the basics of healthy eating and physical activity — monitoring what we eat, eating less fat and fewer calories, looking at how we eat, being physically active, and balancing eating and activity for weight loss. Understanding forces that shape our eating and activity behaviours (Sessions 7–8) covers balancing eating and activity for weight loss and taking charge of our situation with regard to food and physical activity. Long-term change (Sessions 9–16) covers problem solving, avoiding tempting situations, healthy eating when not at home, overcoming challenges to healthy eating, managing stress, and staying motivated.",
        "Program goals: The program has two goals — lose 7% of your weight through healthy eating, and do at least 150 minutes of brisk physical activity each week. These goals are gradual, healthy and safe, and reasonable — not extreme, but attainable.\n\nKey message: This is a program to prevent type 2 diabetes, not a weight-loss program. The amount of weight loss needed to reduce risk may be less than participants anticipate or hope for — the goal is to lose enough weight to prevent type 2 diabetes, though the program does not discourage losing more than that."
      ]),
      HandoutItem(4, 'Why Manage Weight?', pages: [
        "Effect of reaching goals: Reaching your weight loss and activity goals may prevent you from getting type 2 diabetes or heart disease. It will make you look and feel better, make you healthier in general, and set a good example for your family, friends, and community.",
        "Other benefits of making healthier food choices, losing weight, and increasing physical activity: relieves tension; helps us sleep better; lowers blood pressure; lowers LDL (\"bad\") cholesterol and raises HDL (\"good\") cholesterol; helps you get around more easily by making your joints more flexible.\n\nReaching your weight loss and activity goals may lower your risk of some cancers. Being more physically active makes it easier to do daily activities such as carry groceries, climb stairs, and play with children or grandchildren."
      ]),
    ]),
    SessionHandout('Session 2: Become a Fat & Calorie Detective', [
      HandoutItem(1, 'Understanding Calories', pages: [
        "Fat is something we can see, so it's easier to define than calories — calories are more complex. A calorie is a unit of energy supplied by food. Calories in food come from fat, carbohydrates (starches, sugar), protein, or alcohol. A calorie is a calorie regardless of its source — carbohydrates, fats, sugars, and proteins all contain calories.",
        "Fat is the most concentrated source of calories: each gram of fat contains nine calories, more than twice the calories in a gram of carbohydrate or protein. (On a nutrition label, calories per gram are listed as: fat 9, carbohydrate 4, protein 4.) A useful rule of thumb for weight loss: 1 pound of body fat equals 3,500 calories.",
        "To lose 1 pound a week, reduce weekly intake by 3,500 calories — about 500 fewer calories a day. This program aims for 1 to 2 pounds a week, meaning a reduction of 500 to 1,000 calories a day.",
        "Everyone is assigned a personal number of daily fat grams — a fat gram budget — based on present weight and the 7% weight-loss goal; the fat gram goal should be about 25% of total calorie intake. Keep a running subtotal of fat grams throughout the day — add up fat grams as you eat them, the way you keep a running balance in a check book, so you always know how many fat grams you have left for the rest of the day."
      ]),
      HandoutItem(2, 'Understanding Fat', pages: [
        "Fat is essential — it gives our bodies energy, supports cell growth, helps protect our organs, helps keep our bodies warm, helps our bodies absorb some nutrients, and helps produce important hormones. Our bodies need fat, but not as much as most people eat. When we eat too much, our bodies store what they don't need as excess body tissue.",
        "Reasons to eat less fat: it contains more than twice as many calories as the same amount of carbohydrate or protein; even a small amount of high-fat food is high in calories (a tablespoon of butter has 100 calories); and you get less volume for the calories, so low-fat foods may help you feel fuller.",
        "Effects of too much fat: excess fat is associated with heart disease and type 2 diabetes; eating a lot of fat can increase blood cholesterol, and the higher the cholesterol, the greater the chances of a heart attack; some evidence shows eating a lot of fat can increase the chance of getting type 2 diabetes; and people with prediabetes often have trouble metabolizing fat."
      ]),
      HandoutItem(3, 'Fat in Foods', pages: [
        "Nuts are included in the protein group. Although nuts are high in fat, many nuts contain healthy fat. Food groups that tend to be high in fat: meats (contain fat we can see and fat we cannot see); dairy foods (whole milk, regular cheese, ice cream); snack foods such as potato chips; butter, margarine; gravy, mayonnaise, salad dressing; baked goods (cookies, cakes, muffins); fat added through cooking, especially deep-frying (oil, lard, shortening).",
        "These foods can be hard to stop eating because many are widely available, we like the taste, and they may be traditional family or cultural foods."
      ]),
      HandoutItem(4, 'Hidden Calories and Hidden Fats', pages: [
        "Most of the fat we eat (70%) is hidden in food — it isn't obvious that fat is there. Examples: marbling in meats, baked products, sauces and salad dressings, batter coatings on deep-fried foods.",
        "Even small measurement errors add up — just two extra tablespoons of granola on top of an unlevelled measuring cup adds about 3 grams of fat."
      ]),
      HandoutItem(5, 'Why Hidden Calories Matter', pages: [
        "Example: a fast-food lunch of a fried fish sandwich, large French fries, a fried apple turnover, and a milkshake with ice cream adds up to 74 grams of fat (20 teaspoons) and 1,482 calories. Much of that fat comes from how the food is cooked — fried; the milkshake alone has 22 teaspoons of fat, the equivalent of eating almost an entire stick of butter.",
        "On packaged foods, the serving size on the label may be smaller than the amount most of us would naturally serve ourselves — if you eat a larger serving than the label size, you'll be eating more calories and fat grams than the label shows.",
        "Low-fat or fat-free products often still contain a lot of calories — some are very high in calories because they're loaded with sugar (example: ½ cup of low-fat frozen yogurt can have between 110–180 calories). Check the label."
      ]),
    ]),
    SessionHandout('Session 3: Reducing Fat & Calories', [
      HandoutItem(1, 'Reducing Fat Intake: Measuring and Preparation', pages: [
        "Weighing and measuring food are important ways of knowing what we eat; measuring helps us make healthier choices, and eating even a slightly smaller amount can make a big difference in fat grams and calories. Many people feel they don't need to weigh or measure because they think they know how much they eat — but most are surprised when they actually do measure; our eyes can play tricks on us.",
        "Measurement basics: cup (c) = 8 ounces or 16 tablespoons; tablespoon (T/Tbsp) = 3 teaspoons; teaspoon (t/tsp) = the amount in a regular-size spoon; ounce (oz) = 28 grams; gram (g) = the weight of a paper clip.\n\nTips: use a metal or plastic measuring cup for solid foods, filling and levelling off; use a glass measuring cup for liquids, reading at eye level; use a scale for meat, fish, cheese, bread, pasta — weigh meat after cooking and remove fat/bone first (4 oz raw meat ≈ 3 oz cooked, about the size of a deck of cards); use measuring spoons for both solids and liquids, levelling off solids.",
        "When measuring liquids, pour the liquid into the cup and read the measurement at eye level while the cup is resting on a flat surface — reading from above may give an inaccurate measurement. Even a small mistake in estimating amounts can make a big difference in daily fat grams.\n\nHow a food is prepared can cut fat significantly: roast red meat, chuck, untrimmed (22g fat, 286 cal) vs. roast red meat, top round, trimmed (4g fat, 153 cal); chicken breast with skin, breaded and fried (24g fat, 439 cal) vs. chicken breast without skin, grilled (9g fat, 205 cal); flounder, deep fried vs. flounder, baked without fat (4g fat and 64 calories more for the fried version)."
      ]),
      HandoutItem(2, 'Everyday Fat Reduction Strategies', pages: [
        "Three ways to eat less fat and fewer calories: eat high-fat/high-calorie foods less often, eat smaller amounts of them, or eat low-fat/low-calorie foods instead. Examples: French fries once a week instead of daily saves about 132 grams of fat a week; using a regular spoon instead of a salad-bar ladle for dressing means eating only about a quarter of the fat (24 fewer grams); choosing non-fat milk instead of whole milk.",
        "Comparison examples: potato chips (1 oz, 11g fat, 161 cal) vs. pretzels (1 oz, 1g fat, 108 cal); regular margarine (1 tsp, 4g fat, 34 cal) vs. low-fat margarine (1 tsp, 2g fat, 17 cal); baked potato with sour cream (6g fat, 56 cal) vs. with salsa (0g fat, 8 cal).",
        "Menu Makeover swaps: fried eggs → corn flakes; whole milk → skim milk; toast with margarine → toast with jam; coffee with half & half → coffee with non-fat creamer; glazed doughnut → apple; 1 Tbsp mayonnaise → 1 tsp mayonnaise; bologna → turkey breast; regular cheese → low-fat cheese; full bag of chips → half a bag; green beans with bacon → with non-fat broth; salad with French dressing → with fat-free dressing; premium ice cream → an orange. Together, swaps like these saved 107 grams of fat and 1,110 calories in one day's example."
      ]),
      HandoutItem(3, 'Reducing Calories Without Feeling Deprived', pages: [
        "There are no forbidden foods, no good or bad foods — you can eat any food in a small amount and still reach your fat gram goal (potato chips, for example, appear on both the high-fat and lower-fat example menus).",
        "Managing fat grams is like managing money: you have a budget and don't spend more than it allows, keeping a running total the way you'd keep a running balance in a check-book. Knowing how many fat grams you've already eaten helps you plan later meals — if you know you'll eat a lot of fat at one meal, you can \"bank\" for it by deliberately eating fewer fat grams at another meal to offset the splurge."
      ]),
    ]),
    SessionHandout('Session 4: Healthy Eating for Life', [
      HandoutItem(1, 'Principles of Healthy Eating', pages: [
        "Healthy eating is determined both by what we eat and the way we eat. Set up a regular pattern of eating: spread calories through the day to avoid getting too hungry and losing control; eat 3 meals and 1–2 healthy snacks a day; don't skip meals; eat at the same time each day. Don't worry about cleaning your plate — serve smaller portions to begin with, since the greatest waste of food is eating more than you want or need.",
        "Change your eating environment: eat with others; don't eat while watching TV or doing anything else that takes attention away from the meal; use tools like MyPlate to choose healthier foods in the right amounts.\n\nAvoid the tendency to eat the same foods over and over as a way of simplifying tracking — this may work for a while but often leads to trouble when you deviate out of boredom, and it also means you do not learn how to calculate fat grams and portion sizes for unfamiliar foods."
      ]),
      HandoutItem(2, 'The Plate Method', pages: [
        "MyPlate is a general guide to healthy eating, developed by the U.S. Department of Agriculture, based on the latest research on nutrition and health. It shows the relative portion size of each food group we should eat at meals, tailored to sex, age, and physical activity level.\n\nIts five food groups: Grains (foods from wheat, rice, oats, cornmeal, barley, or other cereal grain); Vegetables (fresh, frozen, canned, or dried vegetables and juices); Fruits (fresh, frozen, canned, or dried fruits and juices); Dairy (milk products, yogurts, cheeses); Protein Foods (meat, poultry, fish, eggs, nuts, peanut butter, beans, seeds).",
        "MyPlate encourages balancing calories (enjoy food but eat less, avoid oversized portions); increasing fruits and vegetables (half your plate), whole grains (at least half your grains), and fat-free or low-fat milk; and reducing high-salt foods and sugary drinks.\n\nGeneral daily ranges used in this program: grains 4–6 oz; vegetables 1½–2½ cups; fruit 1–2 cups; milk 2–3 cups; protein foods 3–6 oz.",
        "Grains split into whole grains (whole-wheat flour, bulgur, oatmeal, whole cornmeal, brown rice) and refined grains (white flour, degermed cornmeal, white bread, white rice); at least half your grains should be whole. The fat in bread and starchy foods is usually added during cooking or at the table (butter, cheese sauce), not inherent to the food.\n\nLow-fat dairy: skim/1% milk, low-fat or nonfat yogurt and cheese, soy milk (lactose-free options help those who react to regular milk). Higher-fat dairy: 2%/whole milk, regular cheese, whole-milk cottage cheese.",
        "For protein, choose leaner cuts, trim visible fat, use low-fat cooking methods; nuts are high in fat but often healthy fat (watch portions); beans aren't high in fat unless cooked with added fat. Foods to limit: bacon, sausage, beans cooked in lard, high-fat lunchmeats, chicken with skin, deep-fried meat or fish.\n\nMain message: MyPlate is only one model — include a variety of foods from all groups rather than eating the same foods repeatedly, which can lead to trouble when you deviate out of boredom. MyPlate was developed by the U.S. Department of Agriculture (USDA) to replace the older MyPyramid food guide."
      ]),
      HandoutItem(3, 'Fruits & Vegetables Deep Dive', pages: [
        "Fruits and vegetables should make up half the food on your plate. Lower-fat vegetable choices: raw leafy vegetables, cooked vegetables, vegetable juice.\n\nVegetables to limit: those with butter, margarine, cream, or cheese sauces, and fried vegetables — vegetables themselves aren't usually high in fat; fat is usually added in cooking or at the table. Better preparations: green salad with low-fat dressing; steamed, roasted, or grilled vegetables; raw vegetables with a low-fat dip.",
        "Lower-fat fruit choices: small fresh fruit, canned fruit or 100% juice, dried fruit (in moderation). Fruits to limit: fruit in pastry, coconuts, large amounts of dried fruit, sugar-sweetened juices/drinks, fruit canned in syrup. Whole fresh fruit is best; unsweetened canned fruit and juice are also good.",
        "Eating low-fat foods may help you feel fuller because you get less volume for the calories. Increasing the amount of vegetables you eat may help you feel more full and satisfied after meals.\n\nGreen leafy vegetables have very few calories because they are mostly water, vitamins, minerals, and fibre — ingredients that contain no calories. Other components in food such as vitamins, minerals, water, and fibre do not contain calories. Increasing the amount of vegetables you eat can help you feel more full and satisfied after meals without significantly increasing your calorie intake."
      ]),
      HandoutItem(4, 'Starches and Diabetes', pages: [
        "To prevent type 2 diabetes, you do not need to avoid starchy foods like bread, potatoes, and pasta — what matters is the amount eaten. Whole grain breads, cereals, pasta, rice, and starchy vegetables (potatoes, yams, peas, corn) can be part of meals and snacks; for most people with diabetes, 3 or 4 servings of bread, fruit, or starchy foods a day is about right. Whole grain starchy foods are also a good source of fibre, which helps keep your gut healthy."
      ]),
      HandoutItem(5, 'Low-Fat Flavoring & Preparation', pages: [
        "Use low-fat versions of foods (margarine, mayonnaise, cheese, cream cheese, salad dressing, frozen yogurt, sour cream, skim/1% milk).\n\nUse low-fat flavourings: for vegetables/potatoes — low-fat margarine, non-fat sour cream, non-fat broth, low-fat yogurt, salsa, herbs, mustard, lemon juice; for bread — non-fat cream cheese, low-fat margarine, all-fruit jams; for pancakes — fruit, low-calorie syrup, unsweetened applesauce, crushed berries; for salads — non-fat/low-fat dressing, lemon juice, vinegar; for pasta/rice — sauce with low-fat protein and vegetables, white sauce made with skim/1% milk.",
        "Lower fat in meats: buy lean cuts, trim visible fat, remove poultry skin, choose white meat, drain fat after cooking and blot with a paper towel, flavour with BBQ sauce, hot sauce, ketchup, lemon juice, or Worcestershire sauce.",
        "Avoid frying — poach or boil eggs (or scramble with cooking spray), use two egg whites instead of a whole egg, microwave/steam/boil vegetables in a little water, bake/roast/broil/barbecue/grill instead of frying, and for stir-fry use high heat with no more than 1 teaspoon of oil (or cooking spray/fat-free broth)."
      ]),
      HandoutItem(6, 'Mindful Eating Practices', pages: [
        "Eat slowly: pause between bites, put down your fork, drink water with meals, and enjoy the taste of your food. Eating slowly helps you digest food better, be more aware of what you're eating, and be more aware of when you're full.\n\nDo not eat while watching TV, driving, or doing anything else that takes attention away from the meal — focus on enjoying the food. Eat at a table rather than at your desk, in front of a screen, or while doing other activities. Limit other activities while eating — when you eat, just eat."
      ]),
    ]),
  ]),
];

const List<ModuleHandout> activityHandouts = [
  ModuleHandout(2, 'Physical Activity & Weight Loss', [
    SessionHandout('Session 5: Move Those Muscles', [
      HandoutItem(1, 'Understanding Physical Activity',
          content: "Physical activity means moving your body. There are many ways to be physically active — from brisk walking and swimming to dancing and gardening.\n\nJust as you keep track of food intake, you will also keep track of physical activity. Keeping track of physical activity is just as important as keeping track of what you eat. Keeping track helps you understand your behavior with regard to physical activity and helps you reach your goal."),
      HandoutItem(2, 'Why Physical Activity Matters',
          content: "Being physically active is an excellent way to burn calories and to help achieve and maintain goal weight.\n\nThe number of calories you use during physical activity depends on the type of activity (light, moderate, or intense), the amount of time you are active, and how much you weigh. Basically, the amount of calories you use is determined by the amount of weight your body is carrying and the distance it carries that weight."),
      HandoutItem(3, 'Health Benefits of Physical Activity',
          content: "Physical activity can improve general well-being by helping you lose weight and keep it off; perking up your mood and self-esteem; helping with depression and anxiety; giving you more energy; making it easier to do things such as climb stairs and carry groceries; helping reduce stress; and helping you sleep better.\n\nPhysical activity can improve physical fitness by improving muscle tone and body shape; strengthening your heart, lungs, bones, and muscles; making your joints more flexible; and lowering your risk for back pain and injuries.\n\nPhysical activity can improve your health by lowering your risk for heart disease and some kinds of cancer; raising HDL cholesterol (\"good\" cholesterol); lowering triglycerides (the amount of fat in the blood); and lowering blood pressure."),
      HandoutItem(4, 'Physical Activity and Insulin Resistance',
          content: "Physical activity may lower your risk for type 2 diabetes by making your body better able to use insulin, and therefore lowering the level of sugar in your blood. Your body will be more sensitive to insulin, which means it will use insulin more efficiently."),
      HandoutItem(5, 'Understanding Activity Intensity',
          content: "\"Brisk\" walking means walking fast enough to breathe heavier than usual, but not so fast that you can't carry on a conversation. If you can easily sing a song, you are not walking fast enough.\n\nChoose moderate kinds of activity such as brisk walking — nothing extreme. If you are just beginning physical activity, start slowly. Work up to a moderate level of activity over time."),
      HandoutItem(6, 'The NDPP Physical Activity Goal',
          content: "The physical activity goal for this program is 150 minutes, or 2½ hours, each week. You can do this in several ways, such as 30 minutes for five days, or break down the 30 minutes into three 10-minute or two 15-minute periods. This amount of physical activity will burn approximately 700 calories per week.\n\nWork up to the 150-minute goal slowly — it may take about 4 weeks. Pick activities you like. Choose moderate types of activities such as brisk walking. Spread the 150 minutes over 3 to 4 days or more per week — for example, start by walking 10 minutes a day for 6 days a week and slowly build up to 25 minutes per walk."),
      HandoutItem(7, 'Getting Started Safely',
          content: "It does not matter what your current activity level is. Start wherever you are, and increase activity level slowly, steadily, and safely. Start slowly; do not do anything too strenuous.\n\nTips for making physical activity easier: walk or do physical activity with another person; have fun; plan activities you like. Brisk walking is an easy way to become and stay physically active — it can be done almost anywhere and all you need is a pair of good shoes.\n\nHaving a good pair of shoes is important to protect you from injury and keep you comfortable. They need to fit well and give you good traction. When buying shoes: wear the kind of socks you'll use during activity; go to the store right after being active as your feet may be slightly larger; the shoes should be comfortable right away with one thumb's width between your longest toe and the end of the shoe; the heel should not pinch or slip."),
    ]),
    SessionHandout('Session 6: Being Active as a Way of Life', [
      HandoutItem(1, 'Making Physical Activity a Lifestyle',
          content: "Having an active lifestyle means making choices to move instead of sit. These choices only take an extra minute or two, but they all make a difference and add up to a more active you.\n\nBeing active does not have to mean trips to the gym or walking for a long time on a treadmill. You can be active anywhere. What is important is finding the time to be active and being active regularly throughout the day. The most important thing is to find the time — in the increments most comfortable to you — to be active throughout your day."),
      HandoutItem(2, 'Starting Safely',
          content: "There are a few easy practices that can help you stay safe while being active: build up to brisk activity slowly; start each session slowly to warm up; end each session slowly to cool down; drink plenty of water before, during, and after activity; wear comfortable socks and keep your feet dry.\n\nWarming up and cooling down should take only 5 to 10 minutes — do your planned activity but more slowly or at a lower intensity for 5 to 10 minutes, then do a few minutes of gentle stretching."),
      HandoutItem(3, 'Types of Physical Activity',
          content: "The sessions discuss planned activity (recorded in your Food and Activity Tracker, whether done all at once or in parts) and lifestyle activity (making active choices throughout the day rather than inactive ones).\n\nLifestyle activity involves choosing to be active when getting somewhere throughout the day — such as taking the stairs instead of the elevator, or parking farther from an entrance."),
      HandoutItem(4, 'Flexibility Activities',
          content: "Stretching is one of the best ways to keep muscles from becoming sore, cramped, or injured. Stretching also helps you be more flexible and feel relaxed.\n\nHow to stretch: do a short warm-up before stretching; move slowly until you feel the muscle stretch (a safe stretch is gentle and relaxing); hold the stretch steady for 15 to 30 seconds (do not bounce); relax, then repeat 3 to 5 times; stretch within your own limits, do not push yourself; breathe slowly and naturally, do not hold your breath. Never stretch if you have pain before you begin; if a stretch causes pain, stop."),
      HandoutItem(5, 'Building Activity Gradually',
          content: "The program goal for physical activity increases each week — starting at 60 minutes in Week 5, 90 minutes in Week 6, 120 minutes in Week 7, working toward 150 minutes per week. Add no less than 15 minutes and no more than 30 minutes each week to a participant's goal.\n\nOnly count activity sessions that last at least 10 minutes — do not include breaks or segments shorter than 10 minutes. To prevent sore muscles or cramps: increase only a little at a time how often, how intensely, and how long you are active; drink plenty of fluids (especially water) before, during, and after being active. If you get a muscle cramp: do mild stretching, stretch the muscle and massage it and repeat until the cramp goes away."),
      HandoutItem(6, 'Reducing Sedentary Time',
          content: "Many people watch several hours of television in the evening but say they have no time to walk — try cutting TV time in half and turn it into walking time.\n\nActive choices during the day include: get off the bus a stop or two early and walk the rest of the way; walk down the hall to talk to a co-worker instead of calling or emailing; walk to a nearby store or church instead of driving; use a rake rather than a leaf blower; stand while on the phone instead of sitting; wash your car instead of going to the car wash.\n\nGet rid of cues for being inactive: reduce TV watching, or be active while you watch TV; rather than pile things at the bottom of the stairs, climb the stairs each time something needs to go up."),
      HandoutItem(7, 'Creating an Activity Plan', pages: [
        "Every day set aside one block of time to be active. Decide on a good time to set aside 20 to 30 minutes to do an activity you enjoy. If one block of time will not work, try smaller blocks: 10 minutes three times a day, or 15 minutes twice a day, or 10 minutes morning/afternoon/evening.\n\nPlan to be active by scheduling physical activity into your day. Write \"Walk\" or \"Swim\" or whatever your planned activity is on your calendar — make physical activity as regular an occurrence as taking a shower or eating lunch. Replace less active blocks of time with active ones (for example, walk for half an hour instead of watching an extra half hour of TV).",
        "Stop exercising and seek medical help if you experience chest pain or discomfort (tightness, pressure, heaviness) in the center of the chest, spreading to shoulders, arms, neck, or back — if it doesn't go away within 2–4 minutes, go to a hospital emergency room. Also call your doctor for severe nausea, shortness of breath, sweating, or feeling faint.\n\nFor sprains, strains, or bruises, use R.I.C.E.: Rest (stop activity, rest a few days); Ice (wrap ice in a towel and apply 10 minutes on, 10 minutes off for first 24–36 hours — never apply unwrapped ice); Compression (wrap with elastic bandage, loosen if fingers or toes feel numb); Elevation (lift injured area above your heart). Call your doctor if you cannot move the injured area or there is sudden severe swelling."
      ]),
    ]),
    SessionHandout('Session 7: Tip the Calorie Balance', [
      HandoutItem(1, 'Understanding Calorie Balance',
          content: "The calorie balance is the difference between the calories you take in through eating and drinking and the calories you use through physical activity and your body's natural energy needs.\n\nOur bodies need calories to survive — calories give us the energy to function; they fuel everything we do, even breathing. Type 2 diabetes is generally caused by a combination of genes (it tends to run in families) and lifestyle (being overweight and inactive). We cannot change our genes, but we can change our lifestyle and lower our risk. Eating healthy meals and doing regular physical activity are the best ways to lower weight and lower risk for type 2 diabetes."),
      HandoutItem(2, 'Where Calories Go',
          content: "Calories in food come from fat, carbohydrates (starches, sugar), protein, or alcohol. There can be big differences in how many calories are in various types of foods: fat has the highest concentration of calories at 9 calories per gram; carbohydrates and protein each have 4 calories per gram; alcohol has 7 calories per gram.\n\nOther components in food (vitamins, minerals, water, fiber) do not have calories — for example, green leafy vegetables have few calories because they are mostly water, vitamins, minerals, and fiber. Many people think of meat as being \"pure protein\" when in fact most meats also contain a lot of fat; fat is where most calories in meat come from. The number of calories you use during physical activity depends on the type of activity, the amount of time you are active, and how much you weigh."),
      HandoutItem(3, 'Understanding Weight Change',
          content: "Weight stays the same when calories-in (food) equal calories-out (activity). Weight increases when calories-in are higher than calories-out. Weight decreases when calories-in are lower than calories-out.\n\nWhen you lose weight and keep it off, your new balance requires maintaining new eating habits and a new activity level."),
      HandoutItem(4, 'Food and Activity Work Together',
          content: "Food and activity work together to determine how much you weigh. To lose weight, you need to tip the balance by increasing calories-out or decreasing calories-in, or both. To lose weight it is best to do both: eat fewer calories and be more active — this will help not only lose weight but also improve health.\n\nOne pound of body fat stores approximately 3,500 calories. To lose 1 pound per week, tip the balance by 3,500 calories (500 fewer calories per day); to lose 1½ pounds per week, 5,250 fewer calories (750 per day); to lose 2 pounds per week, 7,000 fewer calories (1,000 per day). Slow, steady weight loss — about 1 to 2 pounds per week — is the best way to lose body fat. No one should eat fewer than 1,200 calories per day."),
      HandoutItem(5, 'Setting Realistic Expectations and Managing Plateaus',
          content: "A general rule of thumb is that one mile of brisk walking (which takes most people 15 to 20 minutes) uses up about 100 calories. This is a rough estimate — the actual amount varies based on type of activity, duration, and body weight.\n\nThe program expects participants to lose 1 to 2 pounds per week. It is generally recommended that people who are not as close to their weight loss goal aim to lose two pounds per week, and people who are closer to their goal lose one pound per week.\n\nIf you have stayed at the same weight or gained weight, work together to try something new to tip the balance. If you have lost some weight but not as much as expected, you have made progress — try something else to tip the balance further. If you have lost as much as expected or more, you have tipped the calorie balance — keep tipping the balance and you will keep losing weight."),
      HandoutItem(6, 'Tracking Progress',
          content: "By keeping track of calories, you will learn which foods are highest in calories and find ways to cut back. Look up the calories for every food you eat, just like you look up fat grams.\n\nKeeping track helps us understand our behavior and helps us reach our goal. Tipping the calorie balance requires keeping track of calories every day and staying as close as possible to your fat gram goal."),
      HandoutItem(7, 'Long-Term Weight Management',
          content: "Over time, after tipping the balance you will reach a new balance at a lower weight. Making the changes a part of your lifestyle helps keep the weight off.\n\nThe best way to tip the balance is to both reduce the amount you eat and drink and increase the time you are physically active."),
    ]),
  ]),
];

const List<ModuleHandout> psychologyHandouts = [
  ModuleHandout(3, 'Psychology & Behavior Change', [
    SessionHandout('Session 8: Take Charge of What\'s Around You', [
      HandoutItem(1, 'Understanding Behaviour Triggers',
          content: "Scientists who study how people learn call the factors that affect our behavior \"cues.\" Cues can be positive or negative.\n\nFood cues are factors that affect how much we eat. Activity cues are factors that affect our level of activity. Cues are a problem when they have a negative effect on our behavior, and lead us to overeat or be inactive.\n\nWhen we respond to a food cue in the same way over and over again, we build a habit. When faced with the food cue, the response becomes more and more automatic — once a habit forms, it becomes hard to break."),
      HandoutItem(2, 'Identifying Food Cues',
          pages: [
            "Common cues that make us want to eat: hunger; what we are thinking or feeling (you might eat because you feel lonely, bored, or happy); what other people say and do (you might eat something because it is offered to you or because other people are eating it); sight or smell of food (one of the most powerful cues); certain activities such as watching TV or reading a magazine.\n\nFood cues are not always bad — hunger is a positive food cue. They can be a problem if they get in the way of efforts to eat less fat and fewer calories. Limit eating to one place — for example, eat at the kitchen table only, not at a desk, in front of a screen, or while driving.",
            "Common problem food cues at home:\n• In the living room (TV, computer, telephone, candy dishes)\n• In the kitchen (ready-to-eat foods such as ice cream, cheese, cookies; food being cooked; leftovers)\n• In the dining room (full serving dishes on the table, large dinner plates, leftovers on plates)\n\nAt work:\n• On the way to work (travelling by a bakery or fast food restaurant)\n• In public areas (doughnuts, high-fat coffee creamers, candy in vending machines)\n• At desk (unhealthy snacks brought from home)\n\nAt the grocery store:\nSupermarkets put new products on the shelves that are easiest to see and reach, because the easier you can spot and pick up a product, the more likely you are to buy it.",
            "Ways to deal with negative food cues:\n• Stay away from the cue or keep it out of sight\n• Build a new, healthier habit by practicing reacting to the cue in a healthier way\n• Add a new cue that helps you lead a healthier life\n\nIt takes time to break an old habit or build a new one — change does not happen overnight. Keep high-fat and high-calorie foods out of your house and workplace, or keep them out of sight (out of sight is out of mind).\n\nKeep low-fat and low-calorie choices easy to reach, in sight, and ready to eat (fresh fruits, raw vegetables, nonfat dips, pretzels, low-fat popcorn)."
          ]),
      HandoutItem(3, 'Identifying Activity Cues',
          content: "Many factors (cues) in our environment can lead to being inactive — for example, after dinner automatically sitting down in front of the TV because you have paired finishing dinner and watching TV many times in the past.\n\nIf you have been inactive for a while, you probably have many cues that trigger inactivity and few that trigger action.\n\nTo become active regularly, you must add positive activity cues to your life. Over time, the cues will lead to activity, and you will develop new habits that become more and more automatic."),
      HandoutItem(4, 'Creating a Healthy Environment',
          content: "Add positive activity cues to your life:\n• Keep exercise equipment (shoes, gym bag, mat, bike) where you can see it most of the time.\n• Keep reminders and motivators visible: calendar of planned activities, fitness videos and magazines, photos and posters of people being active.\n• Set up a regular activity date with a friend or family member.\n• Set a timer or alarm to remind you when it is time to be active.\n• Post motivational reminders on the refrigerator or bathroom mirror.\n• Keep your walking shoes in a visible place at the office.\n• Make a regular daily appointment with yourself to be active — put it in your calendar, it is as important as appointments with other people."),
      HandoutItem(5, 'Taking Control of Your Environment',
          content: "Shopping tips to avoid food cues:\n• Make a shopping list ahead of time and stick to it\n• Avoid shopping when you are hungry\n• Avoid sections in the store that tempt you\n• Ask the grocery store manager to order low-fat and low-calorie foods that you want\n• Use food coupons only for low-fat and low-calorie foods\n\nRemove cues for inactivity:\n• Keep the TV behind closed doors in a cabinet, or do an activity while watching TV\n• Rather than pile things at the bottom of the stairs, climb the stairs each time something needs to go up\n• At work, post a note reminding you to walk at lunch and commit to regular active appointments with yourself."),
    ]),
    SessionHandout('Session 9: Problem Solving', [
      HandoutItem(1, 'Understanding Problems and Barriers',
          content: "Sometimes we run into problems when we try to change our eating habits. Problems can be as small as a schedule change or as big as an injury. No matter what the problem is, we can take steps to keep it from getting in the way of progress toward our goals.\n\nIt is inevitable that problems will occur, but problems can usually be solved. Many factors can get in the way of permanently changing habits: negative thoughts, slips, stress, and social cues."),
      HandoutItem(2, 'Understanding Problem Solving',
          content: "Problem solving is a process — do not give up when you cannot come up with a solution immediately, and do not give up when your first plan does not work. It often takes many tries to find a solution.\n\nFollowing a procedure for solving problems helps us see that we are not powerless to change our situation. Following the five steps helps us be more in control of unexpected setbacks, forces us to be detailed in our search for solutions, helps us break down the problem into small manageable pieces, and helps us see the choices available to us."),
      HandoutItem(3, 'Step 1: Identify the Problem',
          content: "Describe the problem in detail. Be specific about the kinds of food you eat that are high in fat and calories, the situations in which you eat these foods, and the circumstances associated with eating these foods.\n\nLook at what led to the problem and find the action (or behavior) chain — the series of linked events that led up to the behavior.\n\nBreaking a behavior chain into the small events that led up to the behavior makes the problem less overwhelming and more manageable. Breaking the chain into small events uncovers the 'weakest links' where you can break the chain early."),
      HandoutItem(4, 'Step 2: Generate Possible Solutions',
          content: "Think of all possible solutions to the problem. Let the ideas pour out, no matter how extreme or silly they may seem — anything goes; the more ideas the better.\n\nPair options with each event in the action chain that led to the problem. Brainstorming helps you see that you are not powerless to change your situation."),
      HandoutItem(5, 'Step 3: Choose the Best Solution',
          content: "Weigh the pros and cons of each option and choose one, or a combination of several, to try.\n\nBe sure to choose the one you think has the best chance of working, one that you are able to do and are willing to do — be realistic, you should be reasonably confident that you will succeed.\n\nIt is also helpful to break as many links in the action chain as you can, as early as you can."),
      HandoutItem(6, 'Step 4: Try the Solution',
          content: "Make a positive action plan for the option chosen. Spell out exactly what you will do, when you will do it, what you need to do first, and how you will handle any roadblocks that arise.\n\nConsider these to make success more likely:\n• Involve someone else\n• Make your plan fun and enjoyable\n• Write your plan and post it in a prominent place in your home"),
      HandoutItem(7, 'Step 5: Review the Results and Keep Trying!',
          content: "Try the plan. Afterwards ask yourself: Did it work? If not, what went wrong? What can I do next time to make this plan work better? What other plan can I try if this one will not work?\n\nIf your plan does not work, try each step again. Look closely at the events that led to the problem, and try to find other options. Do not give up — it often takes many tries to find a solution that works."),
      HandoutItem(8, 'Building a Problem-Solving Mindset',
          content: "Making changes over sessions with group support can be different from making these changes a lasting part of your lifestyle. The goal for the remaining sessions is to make these changes permanent — focusing on: negative thoughts and how to overcome them; slips and your reactions to them; stress; and social cues.\n\nProblem solving is a skill that requires practice and is to be applied throughout the rest of the program."),
    ]),
    SessionHandout('Session 10: Four Keys to Healthy Eating Out', [
      HandoutItem(1, 'Understanding Challenges of Eating Outside the Home',
          content: "Eating out is a way of life for many people, but it can be a challenge for people who are trying to eat healthy. Eating out and eating healthily can be done simultaneously, but doing so requires planning, effective communication, and careful food selection.\n\nA big challenge to eating out is finding and making good food choices — often a restaurant, dinner party, or event will not have exactly what you want. Be creative, stay committed, and do not worry if the situation is less than perfect."),
      HandoutItem(2, 'Key 1: Plan Ahead',
          content: "Call restaurants or go to their websites to find out about low-fat, low-calorie choices on the menu. Select a restaurant that offers healthy choices (stay away from all-you-can-eat buffets).\n\nEat less fat and fewer calories during other meals during the day when you plan to eat out in the evening — \"bank\" the calories. Eat a small healthy snack before you go out so that you are not too hungry when you arrive.\n\nPlan what to order before you get to the restaurant, and order without looking at the menu. For dinner parties, bring a healthy, low-fat dish to share with others."),
      HandoutItem(3, 'Key 2: Make Healthy Choices',
          content: "You can tell a lot from words on a menu.\n\nHigh-fat words to watch out for: au gratin, breaded, buttered, cheese sauce, creamed/creamy, fried/deep fried, gravy, hollandaise, parmesan, pastry, rich, sautéed.\n\nLow-fat words to look for: baked, broiled, boiled, grilled, poached, roasted, steamed, stir-fried.\n\nAdditional tips: trim visible fat off meat; take skin off chicken; order salad with low-calorie dressing; order regular size rather than large."),
      HandoutItem(4, 'Key 3: Watch Portion Sizes',
          content: "Ask how large the serving size is. Order salad dressing, gravy, sauces, or spreads on the side, and use only a small amount (dip your fork, not the food, into the dressing before each bite — you will use less).\n\nAsk for less cheese or no cheese. Split a main dish or dessert with someone. Order a small size (appetizer, half portion, cup of soup instead of a bowl).\n\nBefore or after the meal, have the amount you do not want to eat put in a container to take home."),
      HandoutItem(5, 'Key 4: Ask for What You Want',
          content: "Be the first to order — you will be less likely to order unhealthy meals that other people order. Keep foods off the table that you do not want to eat (ask the server to remove bread, butter, or chips right away).\n\nAsk the server to remove your plate as soon as you finish. Use a firm and friendly tone of voice that can be heard; repeat your needs until you are heard.\n\nRestaurants expect that people will ask for what they want — you are paying for your meal."),
    ]),
    SessionHandout('Session 11: Talk Back to Negative Thoughts', [
      HandoutItem(1, 'Identifying Negative Thoughts',
          content: "Positive thoughts are thoughts that make us feel good about our progress. Negative thoughts are thoughts that cause us to lose hope or that stand in the way of our progress.\n\nA negative thought is usually a criticism of ourselves. Everyone has negative thoughts at times. Negative thoughts can lead us to overeat or to be inactive.\n\nNegative thinking can become such a habit that we tend to believe and act on our negative thoughts without being aware that we are doing so."),
      HandoutItem(2, 'Understanding Self-Defeating Thinking',
          content: "Types of negative thoughts:\n• Good or Bad (all-or-nothing): \"I ate that cake. I will never succeed.\"\n• Excuses (Rationalizations): \"I have to buy these cookies in case company drops in.\"\n• 'Should' Thoughts: Expects perfection, leading to anger and resentment.\n• 'Not as Good as' Thoughts: Comparing yourself with someone else.\n• 'Give Up' Thoughts: Defeating thoughts like \"This program is too hard, I might as well give up.\""),
      HandoutItem(3, 'Challenging Negative Thoughts',
          content: "Step 1: Catch yourself having the negative thought. Ask yourself, \"Is this thought moving me forward or bringing me down?\" Say to yourself, \"I am being negative about myself.\"\n\nStep 2: Imagine saying \"STOP!\" to yourself — picture a huge, red stop sign so big it takes up all the room in your mind; it should startle you and get rid of the negative thought.\n\nNo matter how effectively you stop a negative thought, building a new positive habit is what makes it lasting."),
      HandoutItem(4, 'Replacing Negative Thoughts',
          content: "Talk back to negative thoughts:\n• Good or Bad → Work toward balance: \"I can eat dessert and cut back on something else. One slip-up is not the end of the world.\"\n• Excuses → It's worth a try: \"It is hard to change old habits, but I will give it a try.\"\n• Should → It is my choice: \"It was my choice. Next time I can decide not to eat so much.\"\n• Not as Good as → Everyone is different: \"It is not a race. We lose weight at different rates.\"\n• Give up → One step at a time: \"I will try something different next time.\""),
      HandoutItem(5, 'Building Self-Confidence',
          content: "Each of us has different kinds of negative or self-defeating thoughts. When these thoughts lead to unhealthy eating or inactivity, use the problem solving process to find the strategies that work best at overcoming self-defeating thoughts.\n\nThe most powerful antidote for negative thoughts is to stop them mid-sentence and counter them with positive thoughts."),
    ]),
    SessionHandout('Session 12: The Slippery Slope of Lifestyle Change', [
      HandoutItem(1, 'Understanding Lifestyle Change',
          content: "We are working toward making lifelong changes to healthy eating and physical activity. Making these changes permanently is different from making them over a series of sessions with group support.\n\nSlips are times when you do not follow your plans for healthy eating or being active. Just about everyone who tries to lose weight and be more active has slips."),
      HandoutItem(2, 'Understanding Lapses',
          content: "Slips are a normal part of lifestyle change — just as falling down is a normal part of skiing. They are to be expected; slips are nearly inevitable.\n\nSlips do not hurt your progress. What hurts your progress is the way you react to slips. What causes you to slip is a habit, something learned over time. Slips are useful learning experiences."),
      HandoutItem(3, 'Understanding the Slippery Slope',
          content: "Slips often begin with a chain of events — a series of small situations, feelings, and behaviors that lead to a slip.\n\nRecognizing the situations and cues that lead to your personal slips helps you plan to avoid them or handle them better. Slips are opportunities to learn about cues and to understand the negative thoughts that follow."),
      HandoutItem(4, 'Lapse vs Relapse',
          content: "A single slip — even an extreme one — will not ruin everything. You will not gain more than a few pounds of weight even after the biggest eating episode imaginable, unless you stay off track and keep overeating time and time again.\n\nThe slip itself is not the problem. The problem occurs only if you do not get back on your feet and keep going toward your goals. Give yourself permission to fall short once in a while."),
      HandoutItem(5, 'Responding to a Lapse',
          pages: [
            "After a slip:\n1. Talk back to negative thoughts with positive thoughts — \"I am not a failure because I slipped. I will get back on my feet again.\"\n2. Ask yourself what happened — look closely at the situation; was it loneliness, boredom, social pressure, or stress?\n3. Regain control as soon as you can — make your very next meal a healthy one and get back on schedule right away.",
            "4. Talk to someone supportive — \"talk it through; do not eat it through\"; call your coach, friend, or family member.\n5. Focus on all the positive changes you made — the same person who slipped is the same person who was successful during many previous weeks.\n\nLearn from the slip: think about how you can avoid similar situations or manage them better."
          ]),
      HandoutItem(6, 'Building Long-Term Success',
          content: "When you slip, it is important to change two habits: the habit that caused the slip and your habitual reaction to the slip.\n\nThe way we react to slips is a habit — you can learn a new way to react that will get you back on your feet. Keep building new positive habits. You are making lifelong changes; slips are just part of the process."),
    ]),
  ]),
];

const List<ModuleHandout> maintenanceHandouts = [
  ModuleHandout(4, 'Long-Term Maintenance', [
    SessionHandout('Session 13: Jump Start Your Activity Plan', [
      HandoutItem(1, 'The Importance of Staying Active'),
      HandoutItem(2, 'Reviewing Your Current Activity'),
      HandoutItem(3, 'Building an Activity Plan'),
      HandoutItem(4, 'Increasing Activity Levels Safely'),
      HandoutItem(5, 'Making Activity a Habit'),
      HandoutItem(6, 'Staying Motivated'),
    ]),
    SessionHandout('Session 14: Make Social Cues Work for You', [
      HandoutItem(1, 'Understanding Social Cues'),
      HandoutItem(2, 'Positive and Negative Social Influences'),
      HandoutItem(3, 'Identifying Your Support Network'),
      HandoutItem(4, 'Communicating Your Goals'),
      HandoutItem(5, 'Building a Supportive Environment'),
      HandoutItem(6, 'Using Social Support During Challenges'),
      HandoutItem(7, 'Long-Term Success Through Social Support'),
    ]),
    SessionHandout('Session 15: You Can Manage Stress', [
      HandoutItem(1, 'Understanding Stress'),
      HandoutItem(2, 'How Stress Affects Lifestyle Habits'),
      HandoutItem(3, 'Healthy Stress Management Strategies'),
      HandoutItem(4, 'Understanding Time Management'),
      HandoutItem(5, 'Improving Time Management'),
      HandoutItem(6, 'Managing Stress During Lifestyle Change'),
    ]),
    SessionHandout('Session 16: Ways to Stay Motivated', [
      HandoutItem(1, 'Understanding Motivation'),
      HandoutItem(2, 'Staying Motivated for the Long Term'),
      HandoutItem(3, 'Balance Your Thoughts for Long-Term Maintenance'),
      HandoutItem(4, 'Handling Holidays, Vacations, and Special Events'),
      HandoutItem(5, 'Understanding Relapse Prevention'),
      HandoutItem(6, 'Preventing Relapse'),
      HandoutItem(7, 'Looking Ahead'),
    ]),
  ]),
];

const List<ModuleHandout> graduationHandouts = [
  ModuleHandout(5, 'Graduation & Lifelong Health', [
    SessionHandout('Module 5: Graduation & Lifelong Health', [
      HandoutItem(1, 'Looking Back on Your Journey'),
      HandoutItem(2, 'The Power of Small Changes'),
      HandoutItem(3, 'Looking Forward'),
      HandoutItem(4, 'Your Commitment to the Future'),
    ]),
  ]),
];

// NDPP gets both modules combined
const List<ModuleHandout> ndppHandouts = [
  ...foodHandouts,
  ...activityHandouts,
  ...psychologyHandouts,
  ...maintenanceHandouts,
  ...graduationHandouts,
];

/// Finds the handout module containing only the requested session's handouts.
/// [sessionIdentifier] can be an [int] (1..16), a numeric [String] ('1'..'16'), or a sessionId ('session_01').
ModuleHandout? getHandoutForSession(dynamic sessionIdentifier) {
  int? sessionNumber;
  if (sessionIdentifier is int) {
    sessionNumber = sessionIdentifier;
  } else if (sessionIdentifier is String) {
    final digits = sessionIdentifier.replaceAll(RegExp(r'[^0-9]'), '');
    sessionNumber = int.tryParse(digits);
  }

  if (sessionNumber == null || sessionNumber < 1) return null;

  for (final module in ndppHandouts) {
    for (final session in module.sessions) {
      final name = session.sessionName.trim();
      final pattern = RegExp(r'^Session\s+' + sessionNumber.toString() + r'[:\s]', caseSensitive: false);
      if (pattern.hasMatch(name) || (sessionNumber == 16 && name.contains('Module 5'))) {
        return ModuleHandout(
          module.moduleNumber,
          module.moduleName,
          [session],
        );
      }
    }
  }
  return null;
}
