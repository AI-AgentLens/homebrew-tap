cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.914"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.914/agentshield_0.2.914_darwin_amd64.tar.gz"
      sha256 "29dc43d0e3a31a220ecd6cd4b1aaf257a3e07bb7b099cdea4cdbfb66ae164fc7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.914/agentshield_0.2.914_darwin_arm64.tar.gz"
      sha256 "f641b33e45fa173dcc25363e2faac1e69f4f0c6fd7945fbff36ac4f526dda286"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.914/agentshield_0.2.914_linux_amd64.tar.gz"
      sha256 "f6a9ffea39b82f86894c73095bdbc890a4733267b623fda6440eae6aaaaa387b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.914/agentshield_0.2.914_linux_arm64.tar.gz"
      sha256 "9ea9e054590410e90a04391a18f4f6be3a08a07e0b4630e799f1d57afd5f40b9"
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
