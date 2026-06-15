cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1319"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1319/agentshield_0.2.1319_darwin_amd64.tar.gz"
      sha256 "35d2b6aede789127cbe7e8d3654e88c5d7419deab6c5b7fa9f562caf6e4dfcde"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1319/agentshield_0.2.1319_darwin_arm64.tar.gz"
      sha256 "498ddf16372936e9b62c17334b5d1ab24c54f29b8d448ec8de0fd5b3569e3de2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1319/agentshield_0.2.1319_linux_amd64.tar.gz"
      sha256 "3c80298114c6a7163828e79401012300ca3d7eb8e0ae199b061b2911adf71c05"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1319/agentshield_0.2.1319_linux_arm64.tar.gz"
      sha256 "53549265c0c14e9367378fac911c2edec3fb5f46a41220d9892db0237ced7cff"
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
