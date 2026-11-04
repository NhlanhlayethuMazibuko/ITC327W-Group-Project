using Microsoft.AspNetCore.Authentication.Cookies;
using BigBrotherAccommodation.Web.Services;
using Supabase.Extensions.DependencyInjection;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSupabase(
    supabaseUrl: builder.Configuration["Supabase:Url"]!,
    supabaseKey: builder.Configuration["Supabase:Key"]!);

builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<RoomService>();
builder.Services.AddHttpClient();
builder.Services.AddScoped<AdminRoomService>();
builder.Services.AddHttpClient();
builder.Services.AddScoped<SupabaseServer>();
builder.Services.AddScoped<ApplicationService>();
builder.Services.AddScoped<ViewingService>();
builder.Services.AddScoped<AdminCaseService>();
builder.Services.AddScoped<AdminReportsService>();
builder.Services.AddScoped<NotificationService>();
builder.Services.AddScoped<MaintenanceService>();
builder.Services.AddScoped<ProfileService>();

builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.LoginPath = "/Account/SignIn";
        options.AccessDeniedPath = "/Account/SignIn";
        options.ExpireTimeSpan = TimeSpan.FromDays(14);
        options.SlidingExpiration = true;
    });

builder.Services.AddControllersWithViews();

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.MapStaticAssets();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}")
    .WithStaticAssets();


app.Run();
