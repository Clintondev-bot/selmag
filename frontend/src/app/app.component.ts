import { Component, OnInit, inject } from '@angular/core';
import { DecimalPipe } from '@angular/common';
import { Categoria, Health, Producto, ProductoService } from './producto.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [DecimalPipe],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent implements OnInit {
  private api = inject(ProductoService);

  productos: Producto[] = [];
  categorias: Categoria[] = [];
  health: Health | null = null;
  busqueda = '';
  categoriaActiva = '';
  cargando = true;
  error = '';

  ngOnInit(): void {
    this.api.health().subscribe({
      next: h => (this.health = h),
      error: () => (this.health = { api: 'error', db: 'error' })
    });
    this.api.categorias().subscribe({ next: c => (this.categorias = c) });
    this.cargar();
  }

  cargar(): void {
    this.cargando = true;
    this.error = '';
    this.api.productos(this.busqueda, this.categoriaActiva).subscribe({
      next: p => { this.productos = p; this.cargando = false; },
      error: () => { this.error = 'No se pudo conectar con la API.'; this.cargando = false; }
    });
  }

  buscar(texto: string): void {
    this.busqueda = texto.trim();
    this.cargar();
  }

  filtrar(slug: string): void {
    this.categoriaActiva = this.categoriaActiva === slug ? '' : slug;
    this.cargar();
  }

  descuento(p: Producto): number {
    return p.precio_anterior ? Math.round((1 - p.precio / p.precio_anterior) * 100) : 0;
  }
}
