cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2042"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2042/agentshield_0.2.2042_darwin_amd64.tar.gz"
      sha256 "bf8eca963aec77f667ea8c0694c9187373450946466a4d03bb65578eb2af488e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2042/agentshield_0.2.2042_darwin_arm64.tar.gz"
      sha256 "83a72171a37be0ffc72e24bac2a4141f59b336a8cf063640d3266aac566d5d1a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2042/agentshield_0.2.2042_linux_amd64.tar.gz"
      sha256 "1d8a12bedcd0daaa61da490928ea702152fdef29e0adf3166a98ed44f90a0014"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2042/agentshield_0.2.2042_linux_arm64.tar.gz"
      sha256 "b60f46938e6a770caf8e6696ed2bb88a4346467012d8a475782571b3950c7419"
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
