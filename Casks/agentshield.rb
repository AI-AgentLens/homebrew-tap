cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1880"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1880/agentshield_0.2.1880_darwin_amd64.tar.gz"
      sha256 "7ed12101f0e5d1cc4a203bf6503bec69feaf4cf29e961ecb2b936d50f3bb4b31"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1880/agentshield_0.2.1880_darwin_arm64.tar.gz"
      sha256 "d1c746ed43bff8c63e85c834864bf5fb1a1cb595af9c53c1859c12aca9a9adaf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1880/agentshield_0.2.1880_linux_amd64.tar.gz"
      sha256 "0e023275d86b6ea203ded7fcfcc43cbd72fbcae9006ebd152331739805f2909f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1880/agentshield_0.2.1880_linux_arm64.tar.gz"
      sha256 "7f2e7f64a214759a77e48ec078eeb0c1b4329f03747754dc44d7bcbbc455f627"
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
