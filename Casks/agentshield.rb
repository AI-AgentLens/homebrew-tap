cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1334"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1334/agentshield_0.2.1334_darwin_amd64.tar.gz"
      sha256 "c3f8fc5f78cb588d9d052979ed8b9dbb645a08e5ca6d9675bf130e53ed0b3a92"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1334/agentshield_0.2.1334_darwin_arm64.tar.gz"
      sha256 "0e676c00aedd1cccc2405d71c29f1dfeef37d9c866275724a4d250c2ec8e2af5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1334/agentshield_0.2.1334_linux_amd64.tar.gz"
      sha256 "8c201a01b5926d2bfdcab19092cef13c9372afaadaea3f68021483b3fe8bf7af"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1334/agentshield_0.2.1334_linux_arm64.tar.gz"
      sha256 "b05037f376f05c1ab5cebeb69b26d3d64c665a13fd882dd705fb28684b573e43"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
