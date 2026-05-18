cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1025"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1025/agentshield_0.2.1025_darwin_amd64.tar.gz"
      sha256 "60e221537b08d24d08e3c8e48409ffbebf14c1e58da2fc06e26836e56d7dc80c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1025/agentshield_0.2.1025_darwin_arm64.tar.gz"
      sha256 "b5a8bbd1c514604a52cf57920e01a9a55ce7d5541c826653f2ea0bec78b940b8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1025/agentshield_0.2.1025_linux_amd64.tar.gz"
      sha256 "c1998219eae6b06a7329905e521a7dfc44056988b7ebdfbd4d1c75ce0c2483b3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1025/agentshield_0.2.1025_linux_arm64.tar.gz"
      sha256 "eb26ad62bbf255e5f827d86dea24651e473074312a009233526f40fbd7a3c664"
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
