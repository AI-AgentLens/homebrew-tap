cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.750"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.750/agentshield_0.2.750_darwin_amd64.tar.gz"
      sha256 "9fdca9fa1973d34907859a4dcba1c00e98d457d13424face66b3f27731fb38e8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.750/agentshield_0.2.750_darwin_arm64.tar.gz"
      sha256 "01f4d6ed697c601bda14db66bd311ac62020e82a538540f2e84bf4ab81e3d974"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.750/agentshield_0.2.750_linux_amd64.tar.gz"
      sha256 "23df1bbdec57fdab8b40c57f508ce85289898516dcd60d6e05e4aa53a7b48f99"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.750/agentshield_0.2.750_linux_arm64.tar.gz"
      sha256 "085f5e772b44b101f00f717ebde6d185f2397c136edcaaa49ff9b1bea732fa74"
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
