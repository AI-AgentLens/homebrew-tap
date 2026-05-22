cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1076"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1076/agentshield_0.2.1076_darwin_amd64.tar.gz"
      sha256 "ac332309744438bbbda7850182dc2a9b3da3fe5f78f6fec57303bae8ac26d16d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1076/agentshield_0.2.1076_darwin_arm64.tar.gz"
      sha256 "3acd13d7f88c1ab7c2f37836a633416fdf52175e67452d1597d687778fe07fa5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1076/agentshield_0.2.1076_linux_amd64.tar.gz"
      sha256 "abfc90330b76bbc3e6c25c12e43f147f1fe54b5fbc4c0414670352e339c281b2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1076/agentshield_0.2.1076_linux_arm64.tar.gz"
      sha256 "2d478922b6708239e7745c56242b74919f90b76220b39336a3fa46e9a3de545d"
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
