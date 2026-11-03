using Microsoft.AspNetCore.Authentication.Cookies;
using BigBrotherAccommodation.Web.Services;
using Supabase.Extensions.DependencyInjection;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSupabase(
    supabaseUrl: builder.Configuration["Supabase:Url"]!,
    supabaseKey: builder.Configuration["Supabase:Key"]!);

builder.Services.AddHttpClient();
builder.Services.AddScoped<SupabaseServer>();
builder.Services.AddScoped<ProfileService>();
builder.Services.AddScoped<NotificationService>();
builder.Services.AddScoped<AdminRoomService>();
builder.Services.AddScoped<AdminCaseService>();
builder.Services.AddScoped<AdminReportsService>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<RoomService>();
builder.Services.AddScoped<ApplicationService>();
builder.Services.AddScoped<ViewingService>();
builder.Services.AddScoped<MaintenanceService>();

builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.LoginPath = "/Account/SignIn";
        options.AccessDeniedPath = "/Account/SignIn";
        options.ExpireTimeSpan = TimeSpan.FromDays(14);
        options.SlidingExpiration = true;
    });

// Add services to the container.
builder.Services.AddControllersWithViews();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
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
