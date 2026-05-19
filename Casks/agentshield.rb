cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1028"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1028/agentshield_0.2.1028_darwin_amd64.tar.gz"
      sha256 "42f2b82e904e5bb6ca5c10f79f9e6726f012dceb135cb9a39d6c7480b7143818"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1028/agentshield_0.2.1028_darwin_arm64.tar.gz"
      sha256 "921bbce19f3234bfcd1c7107d8a05260f4e11aadd7e46c4d39f70e396c5b1971"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1028/agentshield_0.2.1028_linux_amd64.tar.gz"
      sha256 "67c8f1aa83d1e542b63eb0d1e2dd35e0664312f64fb511f2f894545bfe4abdbe"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1028/agentshield_0.2.1028_linux_arm64.tar.gz"
      sha256 "5b6b80c711627f19b714f6b3074d97938c355354217a6d14eaef2c6a75375b4f"
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
