cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2269"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2269/agentshield_0.2.2269_darwin_amd64.tar.gz"
      sha256 "b9329bb9a068209a130190aa86e8eb4d3d67cb2c226e37dfc423650938eb608f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2269/agentshield_0.2.2269_darwin_arm64.tar.gz"
      sha256 "da6520e4a4d405951f0f2b9b24efab9605942d534915d78fcf951bafdb708bfc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2269/agentshield_0.2.2269_linux_amd64.tar.gz"
      sha256 "6e2eded821ebf8d3137f4d5136bcbd6164e65d6616bbe1e408e68fd5d00b570d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2269/agentshield_0.2.2269_linux_arm64.tar.gz"
      sha256 "ddcf86197c8a90ba42ee5e131fe88d193d677fb65bcf2bb05e5320328d651997"
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
