cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1062"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1062/agentshield_0.2.1062_darwin_amd64.tar.gz"
      sha256 "d6de40df05880c6fee2b938fed581968d2ae52bee4a89394b4ad01d347f83994"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1062/agentshield_0.2.1062_darwin_arm64.tar.gz"
      sha256 "9ef26658934ebddf90662ee8c7197045182157686561864bbe8439efec3a8c42"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1062/agentshield_0.2.1062_linux_amd64.tar.gz"
      sha256 "99bd3c92b057f6028813e83424f080d05fb566c0b40bea8e47158b778fab71e3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1062/agentshield_0.2.1062_linux_arm64.tar.gz"
      sha256 "6062cb78cbcfcc63bf885033f46d0d15b5b2f344262284192b93bfdc5919c437"
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
