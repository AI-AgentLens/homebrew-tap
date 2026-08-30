cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1994"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1994/agentshield_0.2.1994_darwin_amd64.tar.gz"
      sha256 "af98920d2d21b271ecb01e14b1e2fbedbcdac679c0819f2432f95ea86928e5b1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1994/agentshield_0.2.1994_darwin_arm64.tar.gz"
      sha256 "4f67300b25cfb34d72010da1994c972e2868c1c5628137f35695dac4fac2878a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1994/agentshield_0.2.1994_linux_amd64.tar.gz"
      sha256 "59eef3f1efa68965310bde466581161a2ce173e2430893f73ab4cdfc53db42bd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1994/agentshield_0.2.1994_linux_arm64.tar.gz"
      sha256 "f76af57bcf394255ca1b096cd9fa37e8f2c858891c2e0302a9e42df960cb888f"
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
