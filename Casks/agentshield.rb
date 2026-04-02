cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.333"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.333/agentshield_0.2.333_darwin_amd64.tar.gz"
      sha256 "27a87dde22dfde09be3d3bd643237e12d2e838432305ce52fea8361f9531bf40"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.333/agentshield_0.2.333_darwin_arm64.tar.gz"
      sha256 "59daf4cafe07b718168310cbf7cdead853267c9dfd9084ad0e8e0bd72d493a17"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.333/agentshield_0.2.333_linux_amd64.tar.gz"
      sha256 "dee948aa8e340867bc4f0b3d975e42f21e4f517188c10a7597202f8d9921b5d3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.333/agentshield_0.2.333_linux_arm64.tar.gz"
      sha256 "96e184da7cabb6a9bfacaaaf9d0d5613b3d5d0031270f72a1b35db377a52fe90"
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
