import { PageHeader } from "@/components/States";
import {
  EFFECTIVE_DATE,
  LEGAL_DOCS,
  type LegalDoc,
  isLegalDoc,
} from "@/lib/legalContent";
import { cn } from "@/lib/utils";
import { Link, useParams } from "@tanstack/react-router";
import { ArrowLeft } from "lucide-react";

export function LegalPage() {
  const { doc } = useParams({ from: "/app/legal/$doc" });
  const active: LegalDoc = isLegalDoc(doc) ? doc : "privacy";
  const content = LEGAL_DOCS[active];

  return (
    <div data-ocid="legal.page" className="mx-auto max-w-3xl">
      <Link
        to="/discover"
        data-ocid="legal.back.link"
        className="mb-5 inline-flex items-center gap-1.5 text-sm font-medium text-muted-foreground transition-smooth hover:text-foreground"
      >
        <ArrowLeft className="size-4" aria-hidden="true" />
        Back to DilSe
      </Link>

      <div className="animate-fade-up">
        <PageHeader title={content.title} subtitle={content.subtitle} />
        <p className="mt-3 text-xs font-semibold uppercase tracking-widest text-muted-foreground">
          Effective {EFFECTIVE_DATE}
        </p>
      </div>

      <nav
        aria-label="Legal documents"
        data-ocid="legal.tabs"
        className="mt-6 flex gap-2"
      >
        {(["privacy", "terms"] as const).map((key) => (
          <Link
            key={key}
            to="/legal/$doc"
            params={{ doc: key }}
            data-ocid={`legal.tab.${key}`}
            className={cn(
              "inline-flex min-h-11 items-center rounded-full px-4 text-sm font-medium transition-smooth",
              key === active
                ? "bg-gradient-primary text-primary-foreground shadow-subtle"
                : "border border-border bg-card text-muted-foreground hover:bg-secondary hover:text-foreground",
            )}
          >
            {LEGAL_DOCS[key].title}
          </Link>
        ))}
      </nav>

      <div className="mt-6 flex flex-col gap-4">
        {content.sections.map((section, index) => (
          <section
            key={section.id}
            data-ocid={`legal.section.${index + 1}`}
            className="animate-card-enter rounded-lg border border-border bg-card p-5 shadow-card md:p-6"
            style={{ animationDelay: `${index * 60}ms` }}
          >
            <div className="flex items-center gap-3">
              <span className="flex size-9 shrink-0 items-center justify-center rounded-full bg-secondary text-primary">
                {section.icon}
              </span>
              <h2 className="font-display text-lg font-semibold text-foreground">
                {section.title}
              </h2>
            </div>
            <div className="mt-3">{section.body}</div>
          </section>
        ))}
      </div>

      <p className="mt-8 rounded-lg border border-border bg-muted/40 p-4 text-xs leading-relaxed text-muted-foreground">
        Questions about this {content.title.toLowerCase()}? Reach us through the
        help options in your profile. We are happy to explain how your data is
        handled.
      </p>
    </div>
  );
}
