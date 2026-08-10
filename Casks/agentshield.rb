cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1811"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1811/agentshield_0.2.1811_darwin_amd64.tar.gz"
      sha256 "ec00fb5f3d21ceb0914d76e3f640c2b0301ec192d5aba7dc9bd6bc2ac4024419"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1811/agentshield_0.2.1811_darwin_arm64.tar.gz"
      sha256 "563a7a8ec4e08bacea38ac043df0539ad902bbdd4dd26268a642302de44d2c01"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1811/agentshield_0.2.1811_linux_amd64.tar.gz"
      sha256 "8209a7d419058a2862e95c0ab0798f42ce6c168cab6096b3152ed886c5027af2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1811/agentshield_0.2.1811_linux_arm64.tar.gz"
      sha256 "cd88bc2e0c6d97ccbf3349b3ff032f00c20a6c8f2bc5bf16d8b2481d82376a5a"
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
