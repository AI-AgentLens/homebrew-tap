cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.496"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.496/agentshield_0.2.496_darwin_amd64.tar.gz"
      sha256 "32071976a8231d3b7ef649cd78cb934810b1f541321f577309016bb3f6abc004"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.496/agentshield_0.2.496_darwin_arm64.tar.gz"
      sha256 "0eda446d6d6c012780f8a2ecb198026fec548b20c38944a60eaf66dfaf69f1b7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.496/agentshield_0.2.496_linux_amd64.tar.gz"
      sha256 "337bf44659e7ef656c5d157f328385ccd60558408f3b5bdf3fd73ff3303f4ca0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.496/agentshield_0.2.496_linux_arm64.tar.gz"
      sha256 "dce41e6dde338fc701c8d665c86ed2d27aa8d80eedc780551e888595c0d15892"
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
