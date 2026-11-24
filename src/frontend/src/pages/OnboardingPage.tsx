import { useCompleteOnboarding } from "@/hooks/useQueries";
import { ageFromDateOfBirth, apiErrorMessage } from "@/lib/format";
import {
  CITY_OPTIONS,
  GENDER_LABELS,
  INTEREST_OPTIONS,
  RELATIONSHIP_LABELS,
} from "@/lib/labels";
import { cn } from "@/lib/utils";
import {
  Gender,
  type OnboardingInput,
  RelationshipPreferenceEnum,
} from "@/types";
import { useInternetIdentity } from "@caffeineai/core-infrastructure";
import { useNavigate } from "@tanstack/react-router";
import { AlertCircle, ArrowRight, Heart, Sparkles } from "lucide-react";
import { useState } from "react";

const GENDER_VALUES = [
  Gender.female,
  Gender.male,
  Gender.nonBinary,
  Gender.other,
];
const RELATIONSHIP_VALUES = [
  RelationshipPreferenceEnum.longTerm,
  RelationshipPreferenceEnum.casualDating,
  RelationshipPreferenceEnum.friendship,
  RelationshipPreferenceEnum.openToAll,
];

const inputClass =
  "flex h-11 w-full rounded-md border border-input bg-card px-3 text-sm text-foreground shadow-xs outline-none transition-smooth placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/40";

function Field({
  label,
  htmlFor,
  hint,
  children,
}: {
  label: string;
  htmlFor: string;
  hint?: string;
  children: React.ReactNode;
}) {
  return (
    <div className="flex flex-col gap-1.5">
      <label htmlFor={htmlFor} className="text-sm font-medium text-foreground">
        {label}
      </label>
      {children}
      {hint && <p className="text-xs text-muted-foreground">{hint}</p>}
    </div>
  );
}

export function OnboardingPage() {
  const navigate = useNavigate();
  const { clear } = useInternetIdentity();
  const completeOnboarding = useCompleteOnboarding();

  const [displayName, setDisplayName] = useState("");
  const [dateOfBirth, setDateOfBirth] = useState("");
  const [gender, setGender] = useState<Gender>(Gender.female);
  const [city, setCity] = useState("");
  const [bio, setBio] = useState("");
  const [interests, setInterests] = useState<string[]>([]);
  const [relationship, setRelationship] = useState<RelationshipPreferenceEnum>(
    RelationshipPreferenceEnum.longTerm,
  );
  const [ageMin, setAgeMin] = useState("21");
  const [ageMax, setAgeMax] = useState("35");
  const [error, setError] = useState<string | null>(null);

  const toggleInterest = (interest: string) => {
    setInterests((current) =>
      current.includes(interest)
        ? current.filter((item) => item !== interest)
        : current.length >= 8
          ? current
          : [...current, interest],
    );
  };

  const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setError(null);

    if (displayName.trim().length < 2) {
      setError("Please enter the name you'd like people to see.");
      return;
    }
    if (!dateOfBirth) {
      setError("Please add your date of birth.");
      return;
    }
    const dobMs = new Date(`${dateOfBirth}T00:00:00Z`).getTime();
    if (Number.isNaN(dobMs)) {
      setError("That date of birth doesn't look right.");
      return;
    }
    const dobNs = BigInt(dobMs) * 1_000_000n;
    if (ageFromDateOfBirth(dobNs) < 18) {
      setError("You must be 18 or older to create a DilSe profile.");
      return;
    }
    if (city.trim() === "") {
      setError("Please choose your city.");
      return;
    }
    if (interests.length === 0) {
      setError("Pick at least one interest so we can find better matches.");
      return;
    }
    const min = Number(ageMin);
    const max = Number(ageMax);
    if (!Number.isFinite(min) || !Number.isFinite(max) || min > max) {
      setError("Your preferred age range needs a valid minimum and maximum.");
      return;
    }

    const input: OnboardingInput = {
      displayName: displayName.trim(),
      dateOfBirth: dobNs,
      gender,
      city: city.trim(),
      bio: bio.trim(),
      interests,
      relationshipPreference: relationship,
      preferredAgeMin: BigInt(min),
      preferredAgeMax: BigInt(max),
    };

    completeOnboarding.mutate(input, {
      onSuccess: (result) => {
        if (result.__kind__ === "ok") {
          void navigate({ to: "/discover" });
        } else {
          setError(apiErrorMessage(result.err));
        }
      },
      onError: () => {
        setError("We couldn't save your profile. Please try again.");
      },
    });
  };

  return (
    <div className="min-h-dvh bg-background">
      <div className="mx-auto max-w-2xl px-4 py-8 sm:px-6">
        <header className="mb-6 flex items-center justify-between">
          <span className="inline-flex items-baseline gap-1 font-display text-2xl font-semibold tracking-tight text-foreground">
            DilSe
            <span className="relative -top-1 inline-flex size-4 items-center justify-center rounded-full bg-gradient-primary text-primary-foreground">
              <Heart className="size-2.5 fill-current" aria-hidden="true" />
            </span>
          </span>
          <button
            type="button"
            data-ocid="onboarding.signout_button"
            onClick={() => clear()}
            className="text-sm text-muted-foreground transition-smooth hover:text-foreground"
          >
            Sign out
          </button>
        </header>

        <div className="animate-fade-up rounded-lg border border-border bg-card p-6 shadow-card sm:p-8">
          <span className="inline-flex items-center gap-1.5 rounded-full border border-accent/30 bg-accent/10 px-3 py-1 text-xs font-semibold text-accent">
            <Sparkles className="size-3.5" aria-hidden="true" />
            Step 1 of 1
          </span>
          <h1 className="mt-4 font-display text-3xl font-semibold text-foreground">
            Let's set up your profile
          </h1>
          <p className="mt-2 text-sm text-muted-foreground">
            Tell us a little about you. You can add photos and edit everything
            later from your profile.
          </p>

          <form
            onSubmit={handleSubmit}
            className="mt-6 flex flex-col gap-5"
            noValidate
          >
            <Field label="Display name" htmlFor="onboarding-name">
              <input
                id="onboarding-name"
                data-ocid="onboarding.name_input"
                className={inputClass}
                value={displayName}
                onChange={(event) => setDisplayName(event.target.value)}
                placeholder="Ananya"
                autoComplete="nickname"
                maxLength={40}
              />
            </Field>

            <div className="grid gap-5 sm:grid-cols-2">
              <Field
                label="Date of birth"
                htmlFor="onboarding-dob"
                hint="You must be 18 or older."
              >
                <input
                  id="onboarding-dob"
                  data-ocid="onboarding.dob_input"
                  type="date"
                  className={inputClass}
                  value={dateOfBirth}
                  onChange={(event) => setDateOfBirth(event.target.value)}
                  max={new Date().toISOString().slice(0, 10)}
                />
              </Field>
              <Field label="City" htmlFor="onboarding-city">
                <select
                  id="onboarding-city"
                  data-ocid="onboarding.city_select"
                  className={inputClass}
                  value={city}
                  onChange={(event) => setCity(event.target.value)}
                >
                  <option value="">Choose your city</option>
                  {CITY_OPTIONS.map((option) => (
                    <option key={option} value={option}>
                      {option}
                    </option>
                  ))}
                </select>
              </Field>
            </div>

            <fieldset className="flex flex-col gap-2">
              <legend className="text-sm font-medium text-foreground">
                I am a
              </legend>
              <div className="flex flex-wrap gap-2">
                {GENDER_VALUES.map((value) => (
                  <button
                    key={value}
                    type="button"
                    data-ocid={`onboarding.gender.${value}.radio`}
                    aria-pressed={gender === value}
                    onClick={() => setGender(value)}
                    className={cn(
                      "min-h-10 rounded-full border px-4 text-sm font-medium transition-smooth",
                      gender === value
                        ? "border-primary bg-primary text-primary-foreground"
                        : "border-border bg-card text-foreground hover:bg-secondary",
                    )}
                  >
                    {GENDER_LABELS[value]}
                  </button>
                ))}
              </div>
            </fieldset>

            <fieldset className="flex flex-col gap-2">
              <legend className="text-sm font-medium text-foreground">
                Looking for
              </legend>
              <div className="flex flex-wrap gap-2">
                {RELATIONSHIP_VALUES.map((value) => (
                  <button
                    key={value}
                    type="button"
                    data-ocid={`onboarding.relationship.${value}.radio`}
                    aria-pressed={relationship === value}
                    onClick={() => setRelationship(value)}
                    className={cn(
                      "min-h-10 rounded-full border px-4 text-sm font-medium transition-smooth",
                      relationship === value
                        ? "border-accent bg-accent text-accent-foreground"
                        : "border-border bg-card text-foreground hover:bg-secondary",
                    )}
                  >
                    {RELATIONSHIP_LABELS[value]}
                  </button>
                ))}
              </div>
            </fieldset>

            <div className="grid gap-5 sm:grid-cols-2">
              <Field label="Preferred age from" htmlFor="onboarding-age-min">
                <input
                  id="onboarding-age-min"
                  data-ocid="onboarding.age_min_input"
                  type="number"
                  min={18}
                  max={99}
                  className={inputClass}
                  value={ageMin}
                  onChange={(event) => setAgeMin(event.target.value)}
                />
              </Field>
              <Field label="Preferred age to" htmlFor="onboarding-age-max">
                <input
                  id="onboarding-age-max"
                  data-ocid="onboarding.age_max_input"
                  type="number"
                  min={18}
                  max={99}
                  className={inputClass}
                  value={ageMax}
                  onChange={(event) => setAgeMax(event.target.value)}
                />
              </Field>
            </div>

            <Field
              label="About you"
              htmlFor="onboarding-bio"
              hint="Optional, up to 300 characters."
            >
              <textarea
                id="onboarding-bio"
                data-ocid="onboarding.bio_textarea"
                className={cn(inputClass, "min-h-24 py-2")}
                value={bio}
                onChange={(event) => setBio(event.target.value)}
                maxLength={300}
                placeholder="A line or two about what makes you, you."
              />
            </Field>

            <fieldset className="flex flex-col gap-2">
              <legend className="text-sm font-medium text-foreground">
                Interests{" "}
                <span className="font-normal text-muted-foreground">
                  ({interests.length}/8)
                </span>
              </legend>
              <div className="flex flex-wrap gap-2">
                {INTEREST_OPTIONS.map((interest) => {
                  const selected = interests.includes(interest);
                  return (
                    <button
                      key={interest}
                      type="button"
                      data-ocid={`onboarding.interest.${interest.toLowerCase().replace(/\s+/g, "-")}.toggle`}
                      aria-pressed={selected}
                      onClick={() => toggleInterest(interest)}
                      className={cn(
                        "min-h-9 rounded-full border px-3 text-sm transition-smooth",
                        selected
                          ? "border-primary bg-secondary font-medium text-primary"
                          : "border-border bg-card text-muted-foreground hover:bg-secondary",
                      )}
                    >
                      {interest}
                    </button>
                  );
                })}
              </div>
            </fieldset>

            {error && (
              <p
                role="alert"
                data-ocid="onboarding.error_state"
                className="flex items-start gap-2 rounded-md border border-destructive/30 bg-destructive/5 px-3 py-2 text-sm text-destructive"
              >
                <AlertCircle
                  className="mt-0.5 size-4 shrink-0"
                  aria-hidden="true"
                />
                {error}
              </p>
            )}

            <button
              type="submit"
              data-ocid="onboarding.submit_button"
              disabled={completeOnboarding.isPending}
              className="inline-flex min-h-12 items-center justify-center gap-2 rounded-full bg-gradient-primary px-6 text-sm font-semibold text-primary-foreground shadow-elevated transition-smooth hover:opacity-95 disabled:opacity-60"
            >
              {completeOnboarding.isPending
                ? "Creating your profile…"
                : "Create my profile"}
              {!completeOnboarding.isPending && (
                <ArrowRight className="size-4" aria-hidden="true" />
              )}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
