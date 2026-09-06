cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2058"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2058/agentshield_0.2.2058_darwin_amd64.tar.gz"
      sha256 "d1eb9ccaacbba1cd33b7b2f4b8762959bcf90e64d65b45f678f62c00d54ff012"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2058/agentshield_0.2.2058_darwin_arm64.tar.gz"
      sha256 "d87bfc90bba846959153f494e11ca20f79f9e48945c7b6f31133e8d40583fcba"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2058/agentshield_0.2.2058_linux_amd64.tar.gz"
      sha256 "816c6b54d126579680f4a32339be7c9cc4a50568adca00e446caba1629b9cb95"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2058/agentshield_0.2.2058_linux_arm64.tar.gz"
      sha256 "175c7573f61bbbee41e9631e53a8b2410e88c57f0847219fc6893ddd0a375b43"
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
