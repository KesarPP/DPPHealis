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
      HandoutItem(1, 'Understanding Physical Activity'),
      HandoutItem(2, 'Why Physical Activity Matters'),
      HandoutItem(3, 'Health Benefits of Physical Activity'),
      HandoutItem(4, 'Physical Activity and Insulin Resistance'),
      HandoutItem(5, 'Understanding Activity Intensity'),
      HandoutItem(6, 'The NDPP Physical Activity Goal'),
      HandoutItem(7, 'Identifying Opportunities to Move More'),
      HandoutItem(8, 'Building an Active Mindset'),
    ]),
    SessionHandout('Session 6: Being Active as a Way of Life', [
      HandoutItem(1, 'Making Physical Activity a Lifestyle'),
      HandoutItem(2, 'Getting Started Safely'),
      HandoutItem(3, 'Types of Physical Activity'),
      HandoutItem(4, 'Finding Activities You Enjoy'),
      HandoutItem(5, 'Reducing Sedentary Time'),
      HandoutItem(6, 'Creating an Activity Plan'),
      HandoutItem(7, 'Choosing Activities'),
    ]),
    SessionHandout('Session 7: Tip the Calorie Balance', [
      HandoutItem(1, 'Understanding Calorie Balance'),
      HandoutItem(2, 'Where Calories Go'),
      HandoutItem(3, 'Understanding Weight Change'),
      HandoutItem(4, 'Food and Activity Work Together'),
      HandoutItem(5, 'Setting Realistic Expectations'),
      HandoutItem(6, 'Understanding Weight Loss Plateaus'),
      HandoutItem(7, 'Tracking Progress'),
      HandoutItem(8, 'Long-Term Weight Management'),
    ]),
  ]),
];

const List<ModuleHandout> psychologyHandouts = [
  ModuleHandout(3, 'Psychology & Behavior Change', [
    SessionHandout('Session 8: Take Charge of What\'s Around You', [
      HandoutItem(1, 'Understanding Behaviour Triggers'),
      HandoutItem(2, 'Understanding Personal Triggers'),
      HandoutItem(3, 'Creating a Healthy Environment'),
    ]),
    SessionHandout('Session 9: Problem Solving', [
      HandoutItem(1, 'Understanding Problems and Barriers'),
      HandoutItem(2, 'Understanding Problem Solving'),
      HandoutItem(3, 'Dealing with Setback'),
      HandoutItem(4, 'Strategies for Future Situations'),
      HandoutItem(5, 'Building a Problem-Solving Mindset'),
    ]),
    SessionHandout('Session 10: Four Keys to Healthy Eating Out', [
      HandoutItem(1, 'Understanding Challenges of Eating Outside the Home'),
      HandoutItem(2, 'Key 1: Plan Ahead'),
      HandoutItem(3, 'Key 2: Make Healthy Choices'),
      HandoutItem(4, 'Key 3: Watch Portion Sizes'),
      HandoutItem(5, 'Key 4: Eat Mindfully'),
    ]),
    SessionHandout('Session 11: Talk Back to Negative Thoughts', [
      HandoutItem(1, 'Identifying Negative Thoughts'),
      HandoutItem(2, 'Understanding Self-Defeating Thinking'),
      HandoutItem(3, 'Challenging Negative Thoughts'),
      HandoutItem(4, 'Replacing Negative Thoughts'),
      HandoutItem(5, 'Building Self-Confidence'),
    ]),
    SessionHandout('Session 12: The Slippery Slope of Lifestyle Change', [
      HandoutItem(1, 'Understanding Lifestyle Change'),
      HandoutItem(2, 'Understanding Lapses'),
      HandoutItem(3, 'Understanding the Slippery Slope'),
      HandoutItem(4, 'Lapse vs Relapse'),
      HandoutItem(5, 'Responding to a Lapse'),
      HandoutItem(6, 'Recognize What Happened'),
      HandoutItem(7, 'Building Long-Term Success'),
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