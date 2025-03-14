using System;
using Microsoft.EntityFrameworkCore;
  // Thay thế bằng namespace chứa class Product của bạn
public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

    public DbSet<Product> Products { get; set; }
}